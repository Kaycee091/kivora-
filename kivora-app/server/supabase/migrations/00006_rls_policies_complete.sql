-- ============================================================================
-- 00006_rls_policies_complete.sql
-- Kivora Comprehensive Row Level Security (RLS) Policies & State Transitions
-- Preserves Zero-Leakage Onboarding, Anti-Spoofing & Atomic Assignment Workflows
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Organizations & Branches (Restricted: No Public Directory Crawling)
-- ----------------------------------------------------------------------------
-- Prospective members validate their specific branch via validate_branch_invite_code.
-- Authenticated users only see organizations and branches they are associated with.

DROP POLICY IF EXISTS "Authenticated users can view organizations" ON public.organizations;
DROP POLICY IF EXISTS "Members and applicants can view their organization" ON public.organizations;
CREATE POLICY "Members and applicants can view their organization"
    ON public.organizations FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.branches b
            WHERE b.organization_id = public.organizations.id
              AND (
                  public.is_branch_member(b.id)
                  OR public.is_branch_manager(b.id)
                  OR public.has_branch_membership_request(b.id)
                  OR b.created_by = auth.uid()
              )
        )
    );

DROP POLICY IF EXISTS "Authenticated users can register organization" ON public.organizations;
CREATE POLICY "Authenticated users can register organization"
    ON public.organizations FOR INSERT
    TO authenticated
    WITH CHECK (true);

DROP POLICY IF EXISTS "Authenticated users can view branches" ON public.branches;
DROP POLICY IF EXISTS "Members and applicants can view assigned branch" ON public.branches;
CREATE POLICY "Members and applicants can view assigned branch"
    ON public.branches FOR SELECT
    TO authenticated
    USING (
        public.is_branch_member(id)
        OR public.is_branch_manager(id)
        OR public.has_branch_membership_request(id)
        OR created_by = auth.uid()
    );

-- Creator identity bound to auth.uid() to eliminate branch spoofing
DROP POLICY IF EXISTS "Authenticated users can create a new branch" ON public.branches;
CREATE POLICY "Authenticated users can create a new branch"
    ON public.branches FOR INSERT
    TO authenticated
    WITH CHECK (created_by = auth.uid());

DROP POLICY IF EXISTS "Branch managers can update their branch" ON public.branches;
CREATE POLICY "Branch managers can update their branch"
    ON public.branches FOR UPDATE
    TO authenticated
    USING (public.is_branch_manager(id))
    WITH CHECK (public.is_branch_manager(id));

-- ----------------------------------------------------------------------------
-- 2. Branch Invite Codes (Least-Privilege: Only Managers Can List & Manage)
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Branch managers can view branch invite codes" ON public.branch_invite_codes;
CREATE POLICY "Branch managers can view branch invite codes"
    ON public.branch_invite_codes FOR SELECT
    TO authenticated
    USING (public.is_branch_manager(branch_id));

DROP POLICY IF EXISTS "Branch managers can create invite codes" ON public.branch_invite_codes;
CREATE POLICY "Branch managers can create invite codes"
    ON public.branch_invite_codes FOR INSERT
    TO authenticated
    WITH CHECK (public.is_branch_manager(branch_id));

DROP POLICY IF EXISTS "Branch managers can update invite codes" ON public.branch_invite_codes;
CREATE POLICY "Branch managers can update invite codes"
    ON public.branch_invite_codes FOR UPDATE
    TO authenticated
    USING (public.is_branch_manager(branch_id))
    WITH CHECK (public.is_branch_manager(branch_id));

-- ----------------------------------------------------------------------------
-- 3. Departments & Classes
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Branch members can view branch departments" ON public.departments;
CREATE POLICY "Branch members can view branch departments"
    ON public.departments FOR SELECT
    TO authenticated
    USING (public.is_branch_member(branch_id) OR public.is_branch_manager(branch_id));

DROP POLICY IF EXISTS "Branch managers can manage departments" ON public.departments;
CREATE POLICY "Branch managers can manage departments"
    ON public.departments FOR ALL
    TO authenticated
    USING (public.is_branch_manager(branch_id))
    WITH CHECK (public.is_branch_manager(branch_id));

DROP POLICY IF EXISTS "Branch members can view branch classes" ON public.classes;
CREATE POLICY "Branch members can view branch classes"
    ON public.classes FOR SELECT
    TO authenticated
    USING (public.is_branch_member(branch_id) OR public.is_branch_manager(branch_id));

DROP POLICY IF EXISTS "Branch managers can manage classes" ON public.classes;
CREATE POLICY "Branch managers can manage classes"
    ON public.classes FOR ALL
    TO authenticated
    USING (public.is_branch_manager(branch_id))
    WITH CHECK (public.is_branch_manager(branch_id));

-- ----------------------------------------------------------------------------
-- 4. Branch Membership Requests & Automated Lifecycle Triggers
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Users can view own membership requests" ON public.branch_membership_requests;
CREATE POLICY "Users can view own membership requests"
    ON public.branch_membership_requests FOR SELECT
    TO authenticated
    USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can submit membership requests" ON public.branch_membership_requests;
CREATE POLICY "Users can submit membership requests"
    ON public.branch_membership_requests FOR INSERT
    TO authenticated
    WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Branch managers can view branch membership requests" ON public.branch_membership_requests;
CREATE POLICY "Branch managers can view branch membership requests"
    ON public.branch_membership_requests FOR SELECT
    TO authenticated
    USING (public.is_branch_manager(branch_id));

DROP POLICY IF EXISTS "Branch managers can update branch membership requests" ON public.branch_membership_requests;
CREATE POLICY "Branch managers can update branch membership requests"
    ON public.branch_membership_requests FOR UPDATE
    TO authenticated
    USING (public.is_branch_manager(branch_id))
    WITH CHECK (public.is_branch_manager(branch_id));

-- Atomic trigger: Increment invite code used_count upon request submission
CREATE OR REPLACE FUNCTION public.handle_membership_request_invite_increment()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
BEGIN
    IF NEW.invite_code_id IS NOT NULL THEN
        UPDATE public.branch_invite_codes
        SET used_count = used_count + 1
        WHERE id = NEW.invite_code_id;
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_membership_invite_increment ON public.branch_membership_requests;
CREATE TRIGGER trg_membership_invite_increment
    AFTER INSERT ON public.branch_membership_requests
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_membership_request_invite_increment();

-- Atomic trigger: Provision user_branch_assignments immediately upon manager approval
CREATE OR REPLACE FUNCTION public.handle_membership_request_approval()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
BEGIN
    IF NEW.status = 'approved' AND (OLD.status IS DISTINCT FROM 'approved') THEN
        INSERT INTO public.user_branch_assignments (
            user_id,
            branch_id,
            role,
            is_active,
            effective_from
        )
        VALUES (
            NEW.user_id,
            NEW.branch_id,
            'member',
            TRUE,
            timezone('utc', now())
        )
        ON CONFLICT DO NOTHING;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_membership_approval_assignment ON public.branch_membership_requests;
CREATE TRIGGER trg_membership_approval_assignment
    AFTER UPDATE ON public.branch_membership_requests
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_membership_request_approval();

-- ----------------------------------------------------------------------------
-- 5. Leave Requests
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Members can view own leave requests" ON public.leave_requests;
CREATE POLICY "Members can view own leave requests"
    ON public.leave_requests FOR SELECT
    TO authenticated
    USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Members can insert own leave requests" ON public.leave_requests;
CREATE POLICY "Members can insert own leave requests"
    ON public.leave_requests FOR INSERT
    TO authenticated
    WITH CHECK (
        user_id = auth.uid()
        AND public.is_branch_member(branch_id)
    );

DROP POLICY IF EXISTS "Managers can view branch leave requests" ON public.leave_requests;
CREATE POLICY "Managers can view branch leave requests"
    ON public.leave_requests FOR SELECT
    TO authenticated
    USING (public.is_branch_manager(branch_id));

DROP POLICY IF EXISTS "Managers can review branch leave requests" ON public.leave_requests;
CREATE POLICY "Managers can review branch leave requests"
    ON public.leave_requests FOR UPDATE
    TO authenticated
    USING (public.is_branch_manager(branch_id))
    WITH CHECK (public.is_branch_manager(branch_id));

-- ----------------------------------------------------------------------------
-- 6. Attendance Correction Requests
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Members can view own correction requests" ON public.correction_requests;
CREATE POLICY "Members can view own correction requests"
    ON public.correction_requests FOR SELECT
    TO authenticated
    USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Members can insert own correction requests" ON public.correction_requests;
CREATE POLICY "Members can insert own correction requests"
    ON public.correction_requests FOR INSERT
    TO authenticated
    WITH CHECK (
        user_id = auth.uid()
        AND EXISTS (
            SELECT 1 FROM public.attendance_records ar
            WHERE ar.id = public.correction_requests.attendance_record_id
              AND ar.user_id = auth.uid()
        )
    );

DROP POLICY IF EXISTS "Managers can view branch correction requests" ON public.correction_requests;
CREATE POLICY "Managers can view branch correction requests"
    ON public.correction_requests FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.attendance_records ar
            WHERE ar.id = public.correction_requests.attendance_record_id
              AND public.is_branch_manager(ar.branch_id)
        )
    );

DROP POLICY IF EXISTS "Managers can review branch correction requests" ON public.correction_requests;
CREATE POLICY "Managers can review branch correction requests"
    ON public.correction_requests FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.attendance_records ar
            WHERE ar.id = public.correction_requests.attendance_record_id
              AND public.is_branch_manager(ar.branch_id)
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.attendance_records ar
            WHERE ar.id = public.correction_requests.attendance_record_id
              AND public.is_branch_manager(ar.branch_id)
        )
    );

-- ----------------------------------------------------------------------------
-- 7. Branch Transfer Requests
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Members can view own transfer requests" ON public.transfer_requests;
CREATE POLICY "Members can view own transfer requests"
    ON public.transfer_requests FOR SELECT
    TO authenticated
    USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Members can insert own transfer requests" ON public.transfer_requests;
CREATE POLICY "Members can insert own transfer requests"
    ON public.transfer_requests FOR INSERT
    TO authenticated
    WITH CHECK (
        user_id = auth.uid()
        AND public.is_branch_member(source_branch_id)
    );

DROP POLICY IF EXISTS "Managers can view related transfer requests" ON public.transfer_requests;
CREATE POLICY "Managers can view related transfer requests"
    ON public.transfer_requests FOR SELECT
    TO authenticated
    USING (
        public.is_branch_manager(source_branch_id) 
        OR public.is_branch_manager(target_branch_id)
    );

DROP POLICY IF EXISTS "Managers can review related transfer requests" ON public.transfer_requests;
CREATE POLICY "Managers can review related transfer requests"
    ON public.transfer_requests FOR UPDATE
    TO authenticated
    USING (
        public.is_branch_manager(source_branch_id) 
        OR public.is_branch_manager(target_branch_id)
    )
    WITH CHECK (
        public.is_branch_manager(source_branch_id) 
        OR public.is_branch_manager(target_branch_id)
    );

-- ----------------------------------------------------------------------------
-- 8. Announcements
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Assigned users can view branch announcements" ON public.announcements;
CREATE POLICY "Assigned users can view branch announcements"
    ON public.announcements FOR SELECT
    TO authenticated
    USING (
        public.is_branch_member(branch_id)
        OR public.is_branch_manager(branch_id)
    );

DROP POLICY IF EXISTS "Managers can manage branch announcements" ON public.announcements;
CREATE POLICY "Managers can manage branch announcements"
    ON public.announcements FOR ALL
    TO authenticated
    USING (public.is_branch_manager(branch_id))
    WITH CHECK (public.is_branch_manager(branch_id));

-- ----------------------------------------------------------------------------
-- 9. Schedule Sessions & Session Assignments
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Assigned users can view branch schedule sessions" ON public.schedule_sessions;
CREATE POLICY "Assigned users can view branch schedule sessions"
    ON public.schedule_sessions FOR SELECT
    TO authenticated
    USING (
        public.is_branch_member(branch_id)
        OR public.is_branch_manager(branch_id)
    );

DROP POLICY IF EXISTS "Managers can manage schedule sessions" ON public.schedule_sessions;
CREATE POLICY "Managers can manage schedule sessions"
    ON public.schedule_sessions FOR ALL
    TO authenticated
    USING (public.is_branch_manager(branch_id))
    WITH CHECK (public.is_branch_manager(branch_id));

DROP POLICY IF EXISTS "Users can view own session assignments" ON public.session_assignments;
CREATE POLICY "Users can view own session assignments"
    ON public.session_assignments FOR SELECT
    TO authenticated
    USING (
        user_id = auth.uid()
        OR EXISTS (
            SELECT 1 FROM public.schedule_sessions s
            WHERE s.id = public.session_assignments.session_id
              AND public.is_branch_manager(s.branch_id)
        )
    );

DROP POLICY IF EXISTS "Managers can manage session assignments" ON public.session_assignments;
CREATE POLICY "Managers can manage session assignments"
    ON public.session_assignments FOR ALL
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.schedule_sessions s
            WHERE s.id = public.session_assignments.session_id
              AND public.is_branch_manager(s.branch_id)
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.schedule_sessions s
            WHERE s.id = public.session_assignments.session_id
              AND public.is_branch_manager(s.branch_id)
        )
    );

-- ----------------------------------------------------------------------------
-- 10. Verification Logs (Telemetry Insert & Branch Protection)
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Users can view own verification logs" ON public.verification_logs;
CREATE POLICY "Users can view own verification logs"
    ON public.verification_logs FOR SELECT
    TO authenticated
    USING (
        user_id = auth.uid()
        OR EXISTS (
            SELECT 1 FROM public.attendance_records ar
            WHERE ar.id = public.verification_logs.attendance_record_id
              AND public.is_branch_manager(ar.branch_id)
        )
    );

DROP POLICY IF EXISTS "Managers can view branch verification logs" ON public.verification_logs;

DROP POLICY IF EXISTS "Members can insert own verification logs" ON public.verification_logs;
CREATE POLICY "Members can insert own verification logs"
    ON public.verification_logs FOR INSERT
    TO authenticated
    WITH CHECK (
        user_id = auth.uid()
        AND (
            attendance_record_id IS NULL
            OR EXISTS (
                SELECT 1 FROM public.attendance_records ar
                WHERE ar.id = public.verification_logs.attendance_record_id
                  AND ar.user_id = auth.uid()
            )
        )
    );
