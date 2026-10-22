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
    const { record_id } = body;

    if (!record_id) {
      return errorResponse(new Error('record_id is required'), 400);
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL') || '';
    const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || '';
    const supabase = createClient(supabaseUrl, serviceKey);

    const { data: record, error: recordErr } = await supabase
      .from('attendance_records')
      .select('*')
      .eq('id', record_id)
      .eq('user_id', user.userId)
      .single();

    if (recordErr || !record) {
      return errorResponse(new Error('Attendance record not found or unauthorized'), 404);
    }

    if (!record.check_in_time) {
      return errorResponse(new Error('Cannot check out without prior check-in'), 400);
    }

    if (record.check_out_time) {
      return errorResponse(new Error('Already checked out'), 400);
    }

    const now = new Date();
    const checkIn = new Date(record.check_in_time);
    const durationSeconds = Math.max(0, Math.floor((now.getTime() - checkIn.getTime()) / 1000));

    const { data: updated, error: updateErr } = await supabase
      .from('attendance_records')
      .update({
        check_out_time: now.toISOString(),
        duration_seconds: durationSeconds,
        updated_at: now.toISOString(),
      })
      .eq('id', record.id)
      .select()
      .single();

    if (updateErr) {
      return errorResponse(updateErr, 500);
    }

    // Log check out event
    await supabase.from('attendance_events').insert({
      attendance_record_id: record.id,
      event_type: 'check_out_confirmed',
      event_timestamp: now.toISOString(),
      client_metadata: { duration_seconds: durationSeconds },
    });

    return jsonResponse({
      record_id: updated.id,
      check_out_time: updated.check_out_time,
      duration_seconds: durationSeconds,
      status: updated.status,
    });
  } catch (err) {
    return errorResponse(err, 500);
  }
});
