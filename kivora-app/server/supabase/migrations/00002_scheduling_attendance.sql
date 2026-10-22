-- ============================================================================
-- 00002_scheduling_attendance.sql
-- Kivora Departments, Classes, Sessions & Attendance Records
-- ============================================================================

-- 1. Departments Table
CREATE TABLE IF NOT EXISTS public.departments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    branch_id UUID NOT NULL REFERENCES public.branches(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- 2. Classes / Groups Table
CREATE TABLE IF NOT EXISTS public.classes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    branch_id UUID NOT NULL REFERENCES public.branches(id) ON DELETE CASCADE,
    department_id UUID REFERENCES public.departments(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    room TEXT,
    instructor_id UUID REFERENCES public.profiles(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- 3. Schedule Sessions Table
CREATE TABLE IF NOT EXISTS public.schedule_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    branch_id UUID NOT NULL REFERENCES public.branches(id) ON DELETE CASCADE,
    class_id UUID REFERENCES public.classes(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    check_in_window_minutes_before INTEGER NOT NULL DEFAULT 15,
    check_in_window_minutes_after INTEGER NOT NULL DEFAULT 30,
    status TEXT NOT NULL DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'in_progress', 'completed', 'cancelled')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- 4. Session Assignments Table
CREATE TABLE IF NOT EXISTS public.session_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES public.schedule_sessions(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    assignment_type TEXT NOT NULL DEFAULT 'required',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    UNIQUE(session_id, user_id)
);

-- 5. Attendance Records Table
CREATE TABLE IF NOT EXISTS public.attendance_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    branch_id UUID NOT NULL REFERENCES public.branches(id) ON DELETE CASCADE,
    session_id UUID NOT NULL REFERENCES public.schedule_sessions(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    check_in_time TIMESTAMPTZ,
    check_out_time TIMESTAMPTZ,
    duration_seconds INTEGER,
    status TEXT NOT NULL DEFAULT 'present' CHECK (status IN ('present', 'late', 'absent', 'half_day', 'needs_review')),
    overall_verification_status TEXT NOT NULL DEFAULT 'passed' CHECK (overall_verification_status IN ('passed', 'failed', 'unavailable', 'needs_review')),
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    UNIQUE(session_id, user_id)
);

-- 6. Attendance Events Table (Immutable timeline of checks, attempts and corrections)
CREATE TABLE IF NOT EXISTS public.attendance_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    attendance_record_id UUID NOT NULL REFERENCES public.attendance_records(id) ON DELETE CASCADE,
    event_type TEXT NOT NULL CHECK (event_type IN ('check_in_attempt', 'check_in_confirmed', 'check_out_attempt', 'check_out_confirmed', 'correction_applied')),
    event_timestamp TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    client_metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- 7. Verification Logs Table (Telemetric audit of biometric, GPS, and network verifications)
CREATE TABLE IF NOT EXISTS public.verification_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    attendance_record_id UUID REFERENCES public.attendance_records(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    verification_factor TEXT NOT NULL CHECK (verification_factor IN ('biometric', 'gps', 'network')),
    result TEXT NOT NULL CHECK (result IN ('passed', 'failed', 'unavailable', 'needs_review')),
    evidence_summary JSONB DEFAULT '{}'::jsonb,
    failure_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- Indexing
CREATE INDEX IF NOT EXISTS idx_sessions_branch_time ON public.schedule_sessions(branch_id, start_time);
CREATE INDEX IF NOT EXISTS idx_attendance_user_date ON public.attendance_records(user_id, check_in_time);
CREATE INDEX IF NOT EXISTS idx_attendance_branch_date ON public.attendance_records(branch_id, check_in_time);
CREATE INDEX IF NOT EXISTS idx_verification_logs_record ON public.verification_logs(attendance_record_id);
