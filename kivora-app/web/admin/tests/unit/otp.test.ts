import { describe, expect, it } from 'vitest';
import { generateOtp, hashOtp, otpMatches, secondsUntilResendAllowed } from '../../src/lib/server/otp';

describe('email verification codes', () => {
  it('generates 6-digit numeric codes', () => {
    for (let i = 0; i < 50; i++) {
      expect(generateOtp()).toMatch(/^\d{6}$/);
    }
  });

  it('matches only the same code, email and secret', () => {
    const hash = hashOtp('User@Example.com', '012345', 'secret');
    expect(otpMatches('user@example.com', '012345', hash, 'secret')).toBe(true);
    expect(otpMatches('user@example.com', '012346', hash, 'secret')).toBe(false);
    expect(otpMatches('other@example.com', '012345', hash, 'secret')).toBe(false);
    expect(otpMatches('user@example.com', '012345', hash, 'other-secret')).toBe(false);
  });

  it('enforces the 60 second resend cooldown', () => {
    const now = new Date('2026-01-01T00:01:00Z');
    expect(secondsUntilResendAllowed(new Date('2026-01-01T00:00:30Z'), now)).toBe(30);
    expect(secondsUntilResendAllowed(new Date('2026-01-01T00:00:00Z'), now)).toBe(0);
  });
});
