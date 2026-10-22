import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.49.1';

export interface UserContext {
  userId: string;
  email: string;
  roles: { branchId: string; role: string }[];
}

export async function verifyAuthToken(req: Request): Promise<UserContext> {
  const authHeader = req.headers.get('Authorization');
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    throw new Error('UNAUTHORIZED: Missing or malformed authorization header');
  }

  const token = authHeader.replace('Bearer ', '');
  const supabaseUrl = Deno.env.get('SUPABASE_URL') || '';
  const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY') || Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || '';

  const client = createClient(supabaseUrl, supabaseKey);
  const { data: { user }, error } = await client.auth.getUser(token);

  if (error || !user) {
    throw new Error(`UNAUTHORIZED: Invalid authentication token (${error?.message || 'User not found'})`);
  }

  // Fetch user active roles and branch assignments
  const { data: assignments } = await client
    .from('user_branch_assignments')
    .select('branch_id, role')
    .eq('user_id', user.id)
    .eq('is_active', true);

  return {
    userId: user.id,
    email: user.email || '',
    roles: (assignments || []).map((a: { branch_id: string; role: string }) => ({
      branchId: a.branch_id,
      role: a.role,
    })),
  };
}

export function hasPermission(
  ctx: UserContext,
  branchId: string,
  requiredRoles: string[] = ['branch_manager', 'branch_admin', 'web_admin']
): boolean {
  return ctx.roles.some((r) => r.branchId === branchId && requiredRoles.includes(r.role));
}

export function jsonResponse(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
  });
}

export function errorResponse(err: unknown, status = 400): Response {
  const message = err instanceof Error ? err.message : String(err);
  return new Response(JSON.stringify({ error: message }), {
    status,
    headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
  });
}
