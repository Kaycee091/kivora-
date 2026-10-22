import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.49.1';
import { errorResponse, jsonResponse, verifyAuthToken } from '../_shared/auth.ts';
import { evaluateVerificationEvidence } from '../_shared/validation.ts';

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: { 'Access-Control-Allow-Origin': '*', 'Access-Control-Allow-Headers': '*' } });
  }

  try {
    const user = await verifyAuthToken(req);
    const body = await req.json();
    const { session_id, verification_evidence } = body;

    if (!session_id) {
      return errorResponse(new Error('session_id is required'), 400);
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL') || '';
    const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || '';
    const supabase = createClient(supabaseUrl, serviceKey);

    // 1. Fetch session details and branch location
    const { data: session, error: sessionErr } = await supabase
      .from('schedule_sessions')
      .select('id, branch_id, start_time, end_time, check_in_window_minutes_before, check_in_window_minutes_after, branches(*)')
      .eq('id', session_id)
      .single();

    if (sessionErr || !session) {
      return errorResponse(new Error('Invalid or non-existent session'), 404);
    }

    // 2. Validate session window
    const now = new Date();
    const startTime = new Date(session.start_time);
    const windowStart = new Date(startTime.getTime() - session.check_in_window_minutes_before * 60000);
    const windowEnd = new Date(startTime.getTime() + session.check_in_window_minutes_after * 60000);

    if (now < windowStart) {
      return errorResponse(new Error('Check-in window has not opened yet'), 400);
    }

    const isLate = now > startTime;
    const status = isLate ? 'late' : 'present';

    // 3. Evaluate verification signals
    const branch = session.branches;
    const evaluation = evaluateVerificationEvidence(
      verification_evidence || {},
      branch?.latitude,
      branch?.longitude,
      branch?.geofence_radius_meters || 100
    );

    // 4. Create or update attendance record
    const { data: record, error: recordErr } = await supabase
      .from('attendance_records')
      .upsert({
        branch_id: session.branch_id,
        session_id: session.id,
        user_id: user.userId,
        check_in_time: now.toISOString(),
        status: evaluation.overallStatus === 'failed' ? 'needs_review' : status,
        overall_verification_status: evaluation.overallStatus,
      }, { onConflict: 'session_id, user_id' })
      .select()
      .single();

    if (recordErr) {
      return errorResponse(recordErr, 500);
    }

    // 5. Log attendance event (immutable)
    await supabase.from('attendance_events').insert({
      attendance_record_id: record.id,
      event_type: 'check_in_confirmed',
      event_timestamp: now.toISOString(),
      client_metadata: { evidence: verification_evidence, evaluation },
    });

    // 6. Log individual verification factors
    await supabase.from('verification_logs').insert([
      {
        attendance_record_id: record.id,
        user_id: user.userId,
        verification_factor: 'biometric',
        result: evaluation.biometricResult,
        evidence_summary: { biometricVerified: verification_evidence?.biometricVerified },
      },
      {
        attendance_record_id: record.id,
        user_id: user.userId,
        verification_factor: 'gps',
        result: evaluation.gpsResult,
        evidence_summary: {
          reportedLat: verification_evidence?.latitude,
          reportedLon: verification_evidence?.longitude,
          distanceMeters: evaluation.details?.distanceMeters,
        },
      },
    ]);

    return jsonResponse({
      record_id: record.id,
      status: record.status,
      verification_status: record.overall_verification_status,
      server_timestamp: now.toISOString(),
      details: evaluation.details,
    });
  } catch (err) {
    return errorResponse(err, 500);
  }
});
