import { parseBody, verifyCode, verifySchema } from '@/lib/server/email-verification';
import { handleError, json, preflight, readJson } from '@/lib/server/http';

export const runtime = 'nodejs';

export const OPTIONS = preflight;

export async function POST(request: Request) {
  try {
    const { email, code } = parseBody(verifySchema, await readJson(request));
    await verifyCode(email, code);
    return json(request, { message: 'Email verified successfully.', email });
  } catch (error) {
    return handleError(request, error);
  }
}
