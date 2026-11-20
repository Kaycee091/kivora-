import { getEmailConfig } from '@/lib/server/env';
import { handleError, json, preflight } from '@/lib/server/http';
import { verifySmtpConnection } from '@/lib/server/mailer';

export const runtime = 'nodejs';
export const dynamic = 'force-dynamic';

export const OPTIONS = preflight;

// Health check: confirms the Brevo SMTP credentials are present and accepted.
export async function GET(request: Request) {
  try {
    const { host, port, fromAddress } = getEmailConfig();
    await verifySmtpConnection();
    return json(request, { ok: true, provider: 'brevo-smtp', host, port, from: fromAddress });
  } catch (error) {
    if (error instanceof Error && 'code' in error && error.code === 'EAUTH') {
      return json(request, { ok: false, error: 'Brevo rejected the SMTP login/key.' }, 502);
    }
    return handleError(request, error);
  }
}
