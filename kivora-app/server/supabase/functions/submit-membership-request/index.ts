import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.49.1';
import { errorResponse, jsonResponse, verifyAuthToken } from '../_shared/auth.ts';

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: { 'Access-Control-Allow-Origin': '*', 'Access-Control-Allow-Headers': '*' } });
  }

  try {
    const user = await verifyAuthToken(req);
    const body = await req.json();
    const { branch_code, requested_role } = body;

    if (!branch_code) {
      return errorResponse(new Error('branch_code is required'), 400);
    }

    const supabase = createClient(Deno.env.get('SUPABASE_URL') || '', Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || '');

    // Validate invite code
    const { data: invite, error: inviteErr } = await supabase
      .from('branch_invite_codes')
      .select('*')
      .eq('code', branch_code.trim().toUpperCase())
      .eq('is_revoked', false)
      .single();

    if (inviteErr || !invite) {
      return errorResponse(new Error('Invalid or expired branch invitation code'), 404);
    }

    if (new Date(invite.expires_at) < new Date()) {
      return errorResponse(new Error('Invitation code has expired'), 400);
    }

    if (invite.used_count >= invite.max_uses) {
      return errorResponse(new Error('Invitation code usage limit reached'), 400);
    }

    // Submit membership request
    const { data: request, error: reqErr } = await supabase
      .from('branch_membership_requests')
      .insert({
        branch_id: invite.branch_id,
        user_id: user.userId,
        invite_code_id: invite.id,
        requested_role: requested_role || 'student',
        status: 'pending',
      })
      .select()
      .single();

    if (reqErr) {
      return errorResponse(reqErr, 500);
    }

    // Increment code used count
    await supabase
      .from('branch_invite_codes')
      .update({ used_count: invite.used_count + 1 })
      .eq('id', invite.id);

    return jsonResponse({
      request_id: request.id,
      status: request.status,
      branch_id: request.branch_id,
    });
  } catch (err) {
    return errorResponse(err, 500);
  }
});
