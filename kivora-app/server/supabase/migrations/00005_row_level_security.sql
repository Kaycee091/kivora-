-- ============================================================================
-- 00005_row_level_security.sql
-- Kivora Row Level Security (RLS) Policies for Branch & Tenant Isolation
-- ============================================================================

-- Enable RLS across all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.branches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_branch_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.branch_invite_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.branch_membership_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.identity_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.schedule_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.session_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.verification_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.leave_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.correction_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transfer_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- 1. Profiles Policies
CREATE POLICY "Users can read own profile"
    ON public.profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update own non-critical profile fields"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id);

-- 2. User Branch Assignments Policies
CREATE POLICY "Users can read own branch assignments"
    ON public.user_branch_assignments FOR SELECT
    USING (user_id = auth.uid());

CREATE POLICY "Branch managers can view assignments in their branch"
    ON public.user_branch_assignments FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.user_branch_assignments mgr
            WHERE mgr.user_id = auth.uid()
            AND mgr.branch_id = public.user_branch_assignments.branch_id
            AND mgr.is_active = TRUE
            AND mgr.role IN ('branch_manager', 'branch_admin', 'web_admin')
        )
    );

-- 3. Attendance Records Policies
CREATE POLICY "Members can view own attendance"
    ON public.attendance_records FOR SELECT
    USING (user_id = auth.uid());

CREATE POLICY "Branch managers can view branch attendance"
    ON public.attendance_records FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.user_branch_assignments mgr
            WHERE mgr.user_id = auth.uid()
            AND mgr.branch_id = public.attendance_records.branch_id
            AND mgr.is_active = TRUE
            AND mgr.role IN ('branch_manager', 'branch_admin', 'web_admin')
        )
    );

-- 4. Identity Documents Policies
CREATE POLICY "Users can view own identity documents"
    ON public.identity_documents FOR SELECT
    USING (user_id = auth.uid());

CREATE POLICY "Branch reviewers can view candidate identity documents"
    ON public.identity_documents FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.branch_membership_requests bmr
            JOIN public.user_branch_assignments mgr ON mgr.branch_id = bmr.branch_id
            WHERE bmr.user_id = public.identity_documents.user_id
            AND mgr.user_id = auth.uid()
            AND mgr.is_active = TRUE
            AND mgr.role IN ('branch_manager', 'branch_admin', 'web_admin')
        )
    );

-- 5. Notifications Policies
CREATE POLICY "Users can read own notifications"
    ON public.notifications FOR SELECT
    USING (user_id = auth.uid());

CREATE POLICY "Users can update own notification read state"
    ON public.notifications FOR UPDATE
    USING (user_id = auth.uid());

-- 6. Audit Logs Policies (Append-only & strictly branch scoped)
CREATE POLICY "Managers can view branch audit history"
    ON public.audit_logs FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.user_branch_assignments mgr
            WHERE mgr.user_id = auth.uid()
            AND mgr.branch_id = public.audit_logs.branch_id
            AND mgr.is_active = TRUE
            AND mgr.role IN ('branch_manager', 'branch_admin', 'web_admin')
        )
    );
