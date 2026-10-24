-- ============================================================================
-- 00005_row_level_security.sql
-- Kivora Row Level Security (RLS) Helper Functions & Core Base Policies
-- Hardened against Privilege Escalation, Data Forgery & Hijacking
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Security Definer Helper Functions
-- ----------------------------------------------------------------------------
-- search_path is locked down to 'public, auth, pg_temp' to eliminate path spoofing.
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.is_branch_manager(lookup_branch_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.user_branch_assignments
        WHERE user_id = auth.uid()
          AND branch_id = lookup_branch_id
          AND is_active = TRUE
          AND role IN ('branch_manager', 'branch_admin', 'web_admin')
    );
$$;

CREATE OR REPLACE FUNCTION public.is_branch_member(lookup_branch_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.user_branch_assignments
        WHERE user_id = auth.uid()
          AND branch_id = lookup_branch_id
          AND is_active = TRUE
    );
$$;

CREATE OR REPLACE FUNCTION public.has_branch_membership_request(lookup_branch_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.branch_membership_requests
        WHERE user_id = auth.uid()
          AND branch_id = lookup_branch_id
    );
$$;

-- Allows fellow branch members & instructors to see each other in schedules/rosters
CREATE OR REPLACE FUNCTION public.shares_active_branch_with(target_user_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.user_branch_assignments u1
        JOIN public.user_branch_assignments u2 ON u1.branch_id = u2.branch_id
        WHERE u1.user_id = auth.uid()
          AND u2.user_id = target_user_id
          AND u1.is_active = TRUE
          AND u2.is_active = TRUE
    );
$$;

-- Secure Invite-Code Validator (Protects against bulk scraping of invite codes)
CREATE OR REPLACE FUNCTION public.validate_branch_invite_code(invite_code TEXT)
RETURNS TABLE (
    branch_id UUID,
    branch_name TEXT,
    organization_id UUID,
    code TEXT,
    allowed_roles TEXT[],
    expires_at TIMESTAMPTZ,
    is_valid BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
BEGIN
    -- Guard against short or empty inputs to prevent enumeration brute-forcing
    IF invite_code IS NULL OR LENGTH(TRIM(invite_code)) < 4 THEN
        RETURN;
    END IF;

    RETURN QUERY
    SELECT 
        b.id AS branch_id,
        b.name AS branch_name,
        b.organization_id,
        bic.code,
        bic.allowed_roles,
        bic.expires_at,
        (bic.is_revoked = FALSE AND bic.expires_at > timezone('utc', now()) AND bic.used_count < bic.max_uses) AS is_valid
    FROM public.branch_invite_codes bic
    JOIN public.branches b ON b.id = bic.branch_id
    WHERE UPPER(TRIM(bic.code)) = UPPER(TRIM(invite_code))
      AND bic.is_revoked = FALSE
      AND bic.expires_at > timezone('utc', now())
      AND bic.used_count < bic.max_uses;
END;
$$;

-- Restrict function execution privileges
REVOKE ALL ON FUNCTION public.is_branch_manager(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.is_branch_manager(UUID) TO authenticated;

REVOKE ALL ON FUNCTION public.is_branch_member(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.is_branch_member(UUID) TO authenticated;

REVOKE ALL ON FUNCTION public.has_branch_membership_request(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.has_branch_membership_request(UUID) TO authenticated;

REVOKE ALL ON FUNCTION public.shares_active_branch_with(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.shares_active_branch_with(UUID) TO authenticated;

REVOKE ALL ON FUNCTION public.validate_branch_invite_code(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.validate_branch_invite_code(TEXT) TO authenticated;

-- ----------------------------------------------------------------------------
-- 2. Enable RLS Across All Tables
-- ----------------------------------------------------------------------------
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
ALTER TABLE public.role_definitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.role_permissions ENABLE ROW LEVEL SECURITY;

-- ----------------------------------------------------------------------------
-- 3. Profiles Policies
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Users can read own profile" ON public.profiles;
CREATE POLICY "Users can read own profile"
    ON public.profiles FOR SELECT
    TO authenticated
    USING (auth.uid() = id);

DROP POLICY IF EXISTS "Managers can read profiles in their branch" ON public.profiles;
CREATE POLICY "Managers can read profiles in their branch"
    ON public.profiles FOR SELECT
    TO authenticated
    USING (
        public.shares_active_branch_with(public.profiles.id)
        OR
        EXISTS (
            SELECT 1 FROM public.user_branch_assignments uba
            WHERE uba.user_id = public.profiles.id
              AND public.is_branch_manager(uba.branch_id)
        )
        OR
        EXISTS (
            SELECT 1 FROM public.branch_membership_requests bmr
            WHERE bmr.user_id = public.profiles.id
              AND public.is_branch_manager(bmr.branch_id)
        )
    );

DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
CREATE POLICY "Users can insert own profile"
    ON public.profiles FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
CREATE POLICY "Users can update own profile"
    ON public.profiles FOR UPDATE
    TO authenticated
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- ----------------------------------------------------------------------------
-- 4. User Branch Assignments Policies (Anti-Hijacking Enforced)
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Users can read own branch assignments" ON public.user_branch_assignments;
CREATE POLICY "Users can read own branch assignments"
    ON public.user_branch_assignments FOR SELECT
    TO authenticated
    USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Branch managers can view assignments in their branch" ON public.user_branch_assignments;
CREATE POLICY "Branch managers can view assignments in their branch"
    ON public.user_branch_assignments FOR SELECT
    TO authenticated
    USING (public.is_branch_manager(branch_id));

DROP POLICY IF EXISTS "Branch managers can insert assignments in their branch" ON public.user_branch_assignments;
CREATE POLICY "Branch managers can insert assignments in their branch"
    ON public.user_branch_assignments FOR INSERT
    TO authenticated
    WITH CHECK (public.is_branch_manager(branch_id));

DROP POLICY IF EXISTS "Branch managers can update assignments in their branch" ON public.user_branch_assignments;
CREATE POLICY "Branch managers can update assignments in their branch"
    ON public.user_branch_assignments FOR UPDATE
    TO authenticated
    USING (public.is_branch_manager(branch_id))
    WITH CHECK (public.is_branch_manager(branch_id));

-- Only the verified creator of the branch can self-assign as initial branch_manager
DROP POLICY IF EXISTS "Users can assign themselves as initial manager of new branch" ON public.user_branch_assignments;
CREATE POLICY "Users can assign themselves as initial manager of new branch"
    ON public.user_branch_assignments FOR INSERT
    TO authenticated
    WITH CHECK (
        user_id = auth.uid()
        AND role = 'branch_manager'
        AND EXISTS (
            SELECT 1 FROM public.branches b
            WHERE b.id = public.user_branch_assignments.branch_id
              AND b.created_by = auth.uid()
        )
        AND NOT EXISTS (
            SELECT 1 FROM public.user_branch_assignments existing
            WHERE existing.branch_id = public.user_branch_assignments.branch_id
        )
    );

-- ----------------------------------------------------------------------------
-- 5. Attendance Records Policies & Anti-Forgery Triggers
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Members can view own attendance" ON public.attendance_records;
CREATE POLICY "Members can view own attendance"
    ON public.attendance_records FOR SELECT
    TO authenticated
    USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Branch managers can view branch attendance" ON public.attendance_records;
CREATE POLICY "Branch managers can view branch attendance"
    ON public.attendance_records FOR SELECT
    TO authenticated
    USING (public.is_branch_manager(branch_id));

DROP POLICY IF EXISTS "Members can insert own attendance record" ON public.attendance_records;
CREATE POLICY "Members can insert own attendance record"
    ON public.attendance_records FOR INSERT
    TO authenticated
    WITH CHECK (
        user_id = auth.uid()
        AND public.is_branch_member(branch_id)
        AND EXISTS (
            SELECT 1 FROM public.schedule_sessions s
            WHERE s.id = public.attendance_records.session_id
              AND s.branch_id = public.attendance_records.branch_id
        )
    );

DROP POLICY IF EXISTS "Members can update own attendance check out" ON public.attendance_records;
CREATE POLICY "Members can update own attendance check out"
    ON public.attendance_records FOR UPDATE
    TO authenticated
    USING (user_id = auth.uid() AND check_out_time IS NULL)
    WITH CHECK (user_id = auth.uid() AND check_out_time IS NOT NULL);

DROP POLICY IF EXISTS "Branch managers can update branch attendance records" ON public.attendance_records;
CREATE POLICY "Branch managers can update branch attendance records"
    ON public.attendance_records FOR UPDATE
    TO authenticated
    USING (public.is_branch_manager(branch_id))
    WITH CHECK (public.is_branch_manager(branch_id));

-- Trigger protecting attendance records from unauthorized client modifications
CREATE OR REPLACE FUNCTION public.check_attendance_record_update_integrity()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
BEGIN
    -- Authorized branch managers can update status, notes, or verification
    IF public.is_branch_manager(OLD.branch_id) THEN
        NEW.updated_at := timezone('utc', now());
        RETURN NEW;
    END IF;

    -- Ordinary members are strictly prohibited from changing status, verification, or timestamps other than checkout
    IF (NEW.status IS DISTINCT FROM OLD.status) OR
       (NEW.overall_verification_status IS DISTINCT FROM OLD.overall_verification_status) OR
       (NEW.check_in_time IS DISTINCT FROM OLD.check_in_time) OR
       (NEW.user_id IS DISTINCT FROM OLD.user_id) OR
       (NEW.session_id IS DISTINCT FROM OLD.session_id) OR
       (NEW.branch_id IS DISTINCT FROM OLD.branch_id) THEN
        RAISE EXCEPTION 'Members are not permitted to alter attendance verification status, check-in timestamps, or session binding.';
    END IF;

    IF NEW.check_out_time IS NOT NULL AND OLD.check_in_time IS NOT NULL AND NEW.check_out_time < OLD.check_in_time THEN
        RAISE EXCEPTION 'check_out_time cannot precede check_in_time.';
    END IF;

    NEW.updated_at := timezone('utc', now());
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_attendance_record_integrity ON public.attendance_records;
CREATE TRIGGER trg_attendance_record_integrity
    BEFORE UPDATE ON public.attendance_records
    FOR EACH ROW
    EXECUTE FUNCTION public.check_attendance_record_update_integrity();

-- ----------------------------------------------------------------------------
-- 6. Attendance Events Policies
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Users can view own attendance events" ON public.attendance_events;
CREATE POLICY "Users can view own attendance events"
    ON public.attendance_events FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.attendance_records ar
            WHERE ar.id = public.attendance_events.attendance_record_id
              AND (ar.user_id = auth.uid() OR public.is_branch_manager(ar.branch_id))
        )
    );

DROP POLICY IF EXISTS "Users can insert own attendance events" ON public.attendance_events;
CREATE POLICY "Users can insert own attendance events"
    ON public.attendance_events FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.attendance_records ar
            WHERE ar.id = public.attendance_events.attendance_record_id
              AND ar.user_id = auth.uid()
        )
    );

-- ----------------------------------------------------------------------------
-- 7. Identity Documents Policies
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Users can view own identity documents" ON public.identity_documents;
CREATE POLICY "Users can view own identity documents"
    ON public.identity_documents FOR SELECT
    TO authenticated
    USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Branch reviewers can view candidate identity documents" ON public.identity_documents;
CREATE POLICY "Branch reviewers can view candidate identity documents"
    ON public.identity_documents FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.branch_membership_requests bmr
            WHERE bmr.user_id = public.identity_documents.user_id
              AND public.is_branch_manager(bmr.branch_id)
        )
    );

DROP POLICY IF EXISTS "Users can insert own identity documents" ON public.identity_documents;
CREATE POLICY "Users can insert own identity documents"
    ON public.identity_documents FOR INSERT
    TO authenticated
    WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can update own pending identity documents" ON public.identity_documents;
CREATE POLICY "Users can update own pending identity documents"
    ON public.identity_documents FOR UPDATE
    TO authenticated
    USING (user_id = auth.uid() AND review_status = 'pending_review')
    WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can delete own pending identity documents" ON public.identity_documents;
CREATE POLICY "Users can delete own pending identity documents"
    ON public.identity_documents FOR DELETE
    TO authenticated
    USING (user_id = auth.uid() AND review_status = 'pending_review');

DROP POLICY IF EXISTS "Branch reviewers can update identity document review status" ON public.identity_documents;
CREATE POLICY "Branch reviewers can update identity document review status"
    ON public.identity_documents FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.branch_membership_requests bmr
            WHERE bmr.user_id = public.identity_documents.user_id
              AND public.is_branch_manager(bmr.branch_id)
        )
    );

-- ----------------------------------------------------------------------------
-- 8. Notifications Policies
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Users can read own notifications" ON public.notifications;
CREATE POLICY "Users can read own notifications"
    ON public.notifications FOR SELECT
    TO authenticated
    USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can update own notification read state" ON public.notifications;
CREATE POLICY "Users can update own notification read state"
    ON public.notifications FOR UPDATE
    TO authenticated
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- ----------------------------------------------------------------------------
-- 9. Audit Logs Policies (Append-only & strictly branch scoped)
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Managers can view branch audit history" ON public.audit_logs;
CREATE POLICY "Managers can view branch audit history"
    ON public.audit_logs FOR SELECT
    TO authenticated
    USING (public.is_branch_manager(branch_id));

DROP POLICY IF EXISTS "Authenticated users and managers can append audit logs" ON public.audit_logs;
CREATE POLICY "Authenticated users and managers can append audit logs"
    ON public.audit_logs FOR INSERT
    TO authenticated
    WITH CHECK (actor_id = auth.uid());

-- ----------------------------------------------------------------------------
-- 10. Role Definitions and Permissions Policies
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Authenticated users can view role definitions" ON public.role_definitions;
CREATE POLICY "Authenticated users can view role definitions"
    ON public.role_definitions FOR SELECT
    TO authenticated
    USING (true);

DROP POLICY IF EXISTS "Managers can manage branch role definitions" ON public.role_definitions;
CREATE POLICY "Managers can manage branch role definitions"
    ON public.role_definitions FOR ALL
    TO authenticated
    USING (branch_id IS NOT NULL AND public.is_branch_manager(branch_id))
    WITH CHECK (branch_id IS NOT NULL AND public.is_branch_manager(branch_id));

DROP POLICY IF EXISTS "Authenticated users can view role permissions" ON public.role_permissions;
CREATE POLICY "Authenticated users can view role permissions"
    ON public.role_permissions FOR SELECT
    TO authenticated
    USING (true);

DROP POLICY IF EXISTS "Managers can manage branch role permissions" ON public.role_permissions;
CREATE POLICY "Managers can manage branch role permissions"
    ON public.role_permissions FOR ALL
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.role_definitions rd
            WHERE rd.id = public.role_permissions.role_id
              AND rd.branch_id IS NOT NULL
              AND public.is_branch_manager(rd.branch_id)
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.role_definitions rd
            WHERE rd.id = public.role_permissions.role_id
              AND rd.branch_id IS NOT NULL
              AND public.is_branch_manager(rd.branch_id)
        )
    );
