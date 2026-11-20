import { parseBody, resendCode, resendSchema } from '@/lib/server/email-verification';
import { handleError, json, preflight, readJson } from '@/lib/server/http';

export const runtime = 'nodejs';

export const OPTIONS = preflight;

export async function POST(request: Request) {
  try {
    const { email } = parseBody(resendSchema, await readJson(request));
    await resendCode(email);
    return json(request, { message: `A new verification code has been sent to ${email}`, email });
  } catch (error) {
    return handleError(request, error);
  }
}
