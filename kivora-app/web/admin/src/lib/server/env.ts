// Server-only configuration. Never import this from client components.

export class ConfigError extends Error {}

function required(name: string): string {
  const value = process.env[name]?.trim();
  if (!value) {
    throw new ConfigError(`Missing required environment variable: ${name}`);
  }
  return value;
}

export function getEmailConfig() {
  return {
    host: process.env.BREVO_SMTP_HOST?.trim() || 'smtp-relay.brevo.com',
    port: Number(process.env.BREVO_SMTP_PORT || 587),
    user: required('BREVO_SMTP_USER'),
    pass: required('BREVO_SMTP_KEY'),
    fromAddress: required('EMAIL_FROM_ADDRESS'),
    fromName: process.env.EMAIL_FROM_NAME?.trim() || 'Kivora',
  };
}

export function getSupabaseAdminConfig() {
  return {
    url: required('NEXT_PUBLIC_SUPABASE_URL'),
    serviceRoleKey: required('SUPABASE_SERVICE_ROLE_KEY'),
  };
}

export function getOtpSecret(): string {
  // Falls back to the service role key so a separate secret is optional.
  return process.env.EMAIL_OTP_SECRET?.trim() || required('SUPABASE_SERVICE_ROLE_KEY');
}

export function getAllowedOrigins(): string[] {
  return (process.env.CORS_ALLOWED_ORIGINS || '')
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean);
}
