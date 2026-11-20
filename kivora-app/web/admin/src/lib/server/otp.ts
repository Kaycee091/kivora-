import { createHmac, randomInt, timingSafeEqual } from 'node:crypto';

export const OTP_EXPIRY_MINUTES = 10;
export const OTP_RESEND_COOLDOWN_SECONDS = 60;
export const OTP_MAX_ATTEMPTS = 5;

export function generateOtp(): string {
  return randomInt(0, 1_000_000).toString().padStart(6, '0');
}

// Keyed hash so a leaked table row can't be brute-forced over the 10^6 code space.
export function hashOtp(email: string, code: string, secret: string): string {
  return createHmac('sha256', secret).update(`${email.toLowerCase()}:${code}`).digest('hex');
}

export function otpMatches(email: string, code: string, storedHash: string, secret: string): boolean {
  const candidate = Buffer.from(hashOtp(email, code, secret), 'hex');
  const stored = Buffer.from(storedHash, 'hex');
  return candidate.length === stored.length && timingSafeEqual(candidate, stored);
}

export function secondsUntilResendAllowed(lastSentAt: Date, now: Date = new Date()): number {
  const elapsed = (now.getTime() - lastSentAt.getTime()) / 1000;
  return Math.max(0, Math.ceil(OTP_RESEND_COOLDOWN_SECONDS - elapsed));
}
