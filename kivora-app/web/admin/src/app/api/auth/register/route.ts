import { parseBody, registerAccount, registerSchema } from '@/lib/server/email-verification';
import { handleError, json, preflight, readJson } from '@/lib/server/http';

export const runtime = 'nodejs';

export const OPTIONS = preflight;

export async function POST(request: Request) {
  try {
    const input = parseBody(registerSchema, await readJson(request));
    await registerAccount(input);
    return json(request, { message: `Verification code sent to ${input.email}`, email: input.email });
  } catch (error) {
    return handleError(request, error);
  }
}
