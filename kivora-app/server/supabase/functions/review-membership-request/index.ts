import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.49.1';
import { errorResponse, hasPermission, jsonResponse, verifyAuthToken } from '../_shared/auth.ts';

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: { 'Access-Control-Allow-Origin': '*', 'Access-Control-Allow-Headers': '*' } });
  }

  try {
    const user = await verifyAuthToken(req);
    const body = await req.json();
    const { request_id, action, reason } = body;

    if (!request_id || !['approve', 'reject', 'needs_information'].includes(action)) {
      return errorResponse(new Error('Valid request_id and action (approve/reject/needs_information) required'), 400);
    }

    const supabase = createClient(Deno.env.get('SUPABASE_URL') || '', Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || '');

    const { data: request, error: reqErr } = await supabase
      .from('branch_membership_requests')
      .select('*')
      .eq('id', request_id)
      .single();

    if (reqErr || !request) {
      return errorResponse(new Error('Membership request not found'), 404);
    }

    // Permission verification on the target branch
    if (!hasPermission(user, request.branch_id)) {
      return errorResponse(new Error('UNAUTHORIZED: You do not have permission to review requests for this branch'), 403);
    }

    const now = new Date().toISOString();
    let newStatus = 'pending';

    if (action === 'approve') {
      newStatus = 'approved';
      // Create user branch assignment
      await supabase.from('user_branch_assignments').insert({
        user_id: request.user_id,
        branch_id: request.branch_id,
        role: 'member',
        is_active: true,
      });
    } else if (action === 'reject') {
      newStatus = 'rejected';
    } else if (action === 'needs_information') {
      newStatus = 'needs_information';
    }

    const { data: updated, error: updateErr } = await supabase
      .from('branch_membership_requests')
      .update({
        status: newStatus,
        decision_reason: reason || null,
        reviewed_by: user.userId,
        reviewed_at: now,
      })
      .eq('id', request.id)
      .select()
      .single();

    if (updateErr) {
      return errorResponse(updateErr, 500);
    }

    // Log administrative action
    await supabase.from('audit_logs').insert({
      actor_id: user.userId,
      branch_id: request.branch_id,
      action: `membership_request_${action}`,
      target_entity: 'branch_membership_requests',
      target_id: request.id,
      changes: { status: newStatus, reason },
    });

    return jsonResponse({
      request_id: updated.id,
      status: updated.status,
      reviewed_at: updated.reviewed_at,
    });
  } catch (err) {
    return errorResponse(err, 500);
  }
});
