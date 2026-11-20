import { createClient, type SupabaseClient } from '@supabase/supabase-js';
import { z } from 'zod';
import { getOtpSecret, getSupabaseAdminConfig } from './env';
import { ApiError } from './http';
import { sendEmail, verificationEmail } from './mailer';
import {
  OTP_EXPIRY_MINUTES,
  OTP_MAX_ATTEMPTS,
  generateOtp,
  hashOtp,
  otpMatches,
  secondsUntilResendAllowed,
} from './otp';

// Accounts are created through the admin API, which never sends email, so all
// verification mail goes out through Brevo via sendEmail().

const CODES_TABLE = 'email_verification_codes';

let adminClient: SupabaseClient | null = null;

function getAdmin(): SupabaseClient {
  if (!adminClient) {
    const { url, serviceRoleKey } = getSupabaseAdminConfig();
    adminClient = createClient(url, serviceRoleKey, {
      auth: { persistSession: false, autoRefreshToken: false },
    });
  }
  return adminClient;
}

const emailSchema = z.string().trim().toLowerCase().email('Please enter a valid email address.').max(254);

export const registerSchema = z.object({
  email: emailSchema,
  password: z.string().min(6, 'Password must be at least 6 characters.').max(72),
  fullName: z.string().trim().min(1, 'Full name is required.').max(120),
});

export const resendSchema = z.object({ email: emailSchema });

export const verifySchema = z.object({
  email: emailSchema,
  code: z.string().trim().regex(/^\d{6}$/, 'Verification code must be exactly 6 digits.'),
});

export function parseBody<T>(schema: z.ZodType<T>, body: unknown): T {
  const result = schema.safeParse(body);
  if (!result.success) {
    throw new ApiError(400, result.error.issues[0]?.message ?? 'Invalid request.');
  }
  return result.data;
}

async function findAuthUser(email: string): Promise<{ id: string; confirmed: boolean } | null> {
  const { data, error } = await getAdmin().rpc('get_auth_user_by_email', { p_email: email });
  if (error) throw new Error(`get_auth_user_by_email failed: ${error.message}`);
  const row = Array.isArray(data) ? data[0] : null;
  return row ? { id: row.id, confirmed: row.email_confirmed_at != null } : null;
}

function authApiError(error: { message: string; status?: number }): Error {
  if (error.status && error.status >= 400 && error.status < 500) {
    return new ApiError(400, error.message);
  }
  return new Error(`Supabase admin auth error: ${error.message}`);
}

async function issueCode(email: string, userId: string, { skipIfCoolingDown }: { skipIfCoolingDown: boolean }) {
  const admin = getAdmin();
  const { data: existing, error: readError } = await admin
    .from(CODES_TABLE)
    .select('last_sent_at')
    .eq('email', email)
    .maybeSingle();
  if (readError) throw new Error(`Reading ${CODES_TABLE} failed: ${readError.message}`);

  if (existing) {
    const wait = secondsUntilResendAllowed(new Date(existing.last_sent_at));
    if (wait > 0) {
      if (skipIfCoolingDown) return;
      throw new ApiError(429, `Please wait ${wait}s before requesting a new code.`, { retryAfterSeconds: wait });
    }
  }

  const code = generateOtp();
  const now = new Date();
  const { error: writeError } = await admin.from(CODES_TABLE).upsert({
    email,
    user_id: userId,
    code_hash: hashOtp(email, code, getOtpSecret()),
    expires_at: new Date(now.getTime() + OTP_EXPIRY_MINUTES * 60_000).toISOString(),
    attempts: 0,
    last_sent_at: now.toISOString(),
  });
  if (writeError) throw new Error(`Writing ${CODES_TABLE} failed: ${writeError.message}`);

  try {
    await sendEmail({ to: email, ...verificationEmail(code, OTP_EXPIRY_MINUTES) });
  } catch (error) {
    console.error('[email] Brevo SMTP send failed', error);
    // Drop the unsent code so the cooldown doesn't block an immediate retry.
    await admin.from(CODES_TABLE).delete().eq('email', email);
    throw new ApiError(502, 'We could not send the verification email. Please try again shortly.');
  }
}

export async function registerAccount(input: z.infer<typeof registerSchema>) {
  const admin = getAdmin();
  const existing = await findAuthUser(input.email);

  if (existing?.confirmed) {
    throw new ApiError(409, 'An account with this email already exists. Please sign in.');
  }

  let userId: string;
  if (existing) {
    // Unverified account re-registering: take the latest password and name.
    const { error } = await admin.auth.admin.updateUserById(existing.id, {
      password: input.password,
      user_metadata: { full_name: input.fullName },
    });
    if (error) throw authApiError(error);
    userId = existing.id;
  } else {
    const { data, error } = await admin.auth.admin.createUser({
      email: input.email,
      password: input.password,
      email_confirm: false,
      user_metadata: { full_name: input.fullName },
    });
    if (error) throw authApiError(error);
    userId = data.user.id;
  }

  await issueCode(input.email, userId, { skipIfCoolingDown: true });
}

export async function resendCode(email: string) {
  const user = await findAuthUser(email);
  if (!user) throw new ApiError(404, 'No account found for this email. Please register first.');
  if (user.confirmed) throw new ApiError(409, 'This email is already verified. Please sign in.');
  await issueCode(email, user.id, { skipIfCoolingDown: false });
}

export async function verifyCode(email: string, code: string) {
  const admin = getAdmin();
  const { data: row, error } = await admin
    .from(CODES_TABLE)
    .select('user_id, code_hash, expires_at, attempts')
    .eq('email', email)
    .maybeSingle();
  if (error) throw new Error(`Reading ${CODES_TABLE} failed: ${error.message}`);

  if (!row) throw new ApiError(400, 'No active verification code. Please request a new one.');
  if (row.attempts >= OTP_MAX_ATTEMPTS) {
    throw new ApiError(429, 'Too many incorrect attempts. Please request a new code.');
  }
  if (new Date(row.expires_at).getTime() < Date.now()) {
    throw new ApiError(400, 'This code has expired. Please request a new one.');
  }

  if (!otpMatches(email, code, row.code_hash, getOtpSecret())) {
    await admin.from(CODES_TABLE).update({ attempts: row.attempts + 1 }).eq('email', email);
    const remaining = OTP_MAX_ATTEMPTS - row.attempts - 1;
    throw new ApiError(
      400,
      remaining > 0
        ? `Invalid verification code. ${remaining} attempt${remaining === 1 ? '' : 's'} left.`
        : 'Too many incorrect attempts. Please request a new code.',
    );
  }

  const { error: confirmError } = await admin.auth.admin.updateUserById(row.user_id, { email_confirm: true });
  if (confirmError) throw authApiError(confirmError);

  await admin.from(CODES_TABLE).delete().eq('email', email);
}
