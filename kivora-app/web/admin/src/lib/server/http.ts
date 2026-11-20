import { NextResponse } from 'next/server';
import { ConfigError, getAllowedOrigins } from './env';

export class ApiError extends Error {
  constructor(public status: number, message: string, public extra: Record<string, unknown> = {}) {
    super(message);
  }
}

function corsHeaders(request: Request): Record<string, string> {
  const origin = request.headers.get('origin');
  if (!origin) return {};
  const allowed = getAllowedOrigins();
  if (!allowed.includes('*') && !allowed.includes(origin)) return {};
  return {
    'Access-Control-Allow-Origin': origin,
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Max-Age': '86400',
    Vary: 'Origin',
  };
}

export function preflight(request: Request) {
  return new NextResponse(null, { status: 204, headers: corsHeaders(request) });
}

export function json(request: Request, body: Record<string, unknown>, status = 200) {
  return NextResponse.json(body, { status, headers: corsHeaders(request) });
}

export async function readJson(request: Request): Promise<Record<string, unknown>> {
  try {
    const body = await request.json();
    return body && typeof body === 'object' ? body : {};
  } catch {
    throw new ApiError(400, 'Request body must be valid JSON.');
  }
}

export function handleError(request: Request, error: unknown) {
  if (error instanceof ApiError) {
    return json(request, { error: error.message, ...error.extra }, error.status);
  }
  if (error instanceof ConfigError) {
    console.error(`[email] ${error.message}`);
    return json(request, { error: 'Email service is not configured on the server.' }, 503);
  }
  console.error('[email] Unexpected error', error);
  return json(request, { error: 'Unexpected server error. Please try again.' }, 500);
}
