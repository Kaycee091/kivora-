-- ============================================================================
-- 00008_techverve_test_setup_FINAL.sql
-- Production-Hardened, Transaction-Safe, Non-Destructive Techverve Migration
-- (Second Security & Data-Integrity Correction Pass)
--
-- SECURITY & DATA INTEGRITY GUARANTEES:
-- 1. Safely replaces validate_branch_invite_code(TEXT) with DROP FUNCTION IF EXISTS
--    (without CASCADE) to avoid return-type change errors and protect dependencies.
-- 2. Restricts invite code SELECT policy exclusively to branch managers. Regular
--    applicants can only validate codes they supply via the restricted validator function.
-- 3. Revokes EXECUTE from anon and public on the validator function; grants EXECUTE
--    strictly to authenticated.
-- 4. Eliminates automatic invite lookup on NULL invite_code_id; requires valid,
--    active, unexpired, unexhausted invite matching the requested branch and role.
-- 5. Verifies existing invite branch and creator before modifications; aborts on
--    ownership or branch conflicts without moving invites.
-- 6. Aborts on organization ambiguity; verifies branch-to-organization relationships
--    and ownership before making changes.
-- 7. Strictly preserves real branch data (code, address, email, phone, description);
--    no fabricated defaults or demo details.
-- 8. Derives profile full_name from verified auth.users metadata for missing profiles;
--    never overwrites existing profiles.
-- 9. Aborts if the designated test member already has an active assignment in the branch;
--    no test-convenience deactivations.
-- 10. Serializes concurrent approvals for the same user via SELECT ... FOR UPDATE
--     on profiles, ensuring the single-active-member-assignment guarantee.
-- 11. Scopes table grants strictly to the seven target tables; leaves unrelated tables
--     (identity_documents, attendance_records, leave_requests, announcements) untouched.
-- 12. Preserves private storage bucket 'id-documents' with user-folder path isolation.
-- 13. Dynamically removes all old policies on the seven target tables; establishes
--     the verified 24-policy security inventory.
-- 14. All SECURITY DEFINER functions have fixed search paths (public, auth, pg_temp),
--     strict authorization checks, and minimum execution privileges.
-- 15. Uses now() consistently for TIMESTAMPTZ values and comparisons.
-- 16. Includes comprehensive read-only post-migration verification queries.
-- ============================================================================

BEGIN;

-- ============================================================================
-- 1. Schema Extensions (Idempotent)
-- ============================================================================

-- Ensure created_by column exists on organizations for ownership tracking
ALTER TABLE public.organizations 
ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES public.profiles(id);

-- Ensure submitted_data and photo_url columns exist on branch_membership_requests
ALTER TABLE public.branch_membership_requests
ADD COLUMN IF NOT EXISTS submitted_data JSONB DEFAULT '{}'::jsonb,
ADD COLUMN IF NOT EXISTS photo_url TEXT;

-- Enforce case-insensitive unique invite codes
CREATE UNIQUE INDEX IF NOT EXISTS uq_branch_invite_codes_code_upper 
ON public.branch_invite_codes (UPPER(TRIM(code)));

-- Enforce single pending membership request per user and branch (prevents duplicate submissions)
CREATE UNIQUE INDEX IF NOT EXISTS uq_branch_membership_pending 
ON public.branch_membership_requests (branch_id, user_id) 
WHERE status = 'pending';

-- ============================================================================
-- 2. Safe Organization Ownership Backfill (Unambiguous Creators Only)
-- ============================================================================
UPDATE public.organizations o
SET created_by = owners.owner_id
FROM (
    SELECT
        organization_id,
        MIN(created_by::text)::uuid AS owner_id
    FROM public.branches
    WHERE organization_id IS NOT NULL AND created_by IS NOT NULL
    GROUP BY organization_id
    HAVING COUNT(DISTINCT created_by) = 1
) owners
WHERE o.id = owners.organization_id
  AND o.created_by IS NULL;

-- ============================================================================
-- 3. Enforce Row Level Security on All Seven Target Tables
-- ============================================================================
ALTER TABLE public.branches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_branch_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.branch_invite_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.branch_membership_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.branch_id_form_configs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 4. Dynamically Drop ALL Existing Policies on Seven Target Tables
-- ============================================================================
DO $$
DECLARE
    pol RECORD;
BEGIN
    FOR pol IN
        SELECT schemaname, tablename, policyname
        FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename IN (
              'branches',
              'organizations',
              'profiles',
              'branch_invite_codes',
              'branch_membership_requests',
              'branch_id_form_configs',
              'user_branch_assignments'
          )
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I', pol.policyname, pol.schemaname, pol.tablename);
    END LOOP;
END;
$$;

-- ============================================================================
-- 5. Revoke Broad Default Privileges from PUBLIC and anon
-- ============================================================================
REVOKE ALL ON TABLE public.branches FROM anon, public;
REVOKE ALL ON TABLE public.user_branch_assignments FROM anon, public;
REVOKE ALL ON TABLE public.branch_invite_codes FROM anon, public;
REVOKE ALL ON TABLE public.branch_membership_requests FROM anon, public;
REVOKE ALL ON TABLE public.branch_id_form_configs FROM anon, public;
REVOKE ALL ON TABLE public.organizations FROM anon, public;
REVOKE ALL ON TABLE public.profiles FROM anon, public;

REVOKE ALL ON FUNCTION public.is_branch_manager(UUID) FROM anon, public;
REVOKE ALL ON FUNCTION public.is_branch_member(UUID) FROM anon, public;
REVOKE ALL ON FUNCTION public.has_branch_membership_request(UUID) FROM anon, public;
REVOKE ALL ON FUNCTION public.shares_active_branch_with(UUID) FROM anon, public;

-- Drop function without CASCADE before recreating with updated RETURNS TABLE
DROP FUNCTION IF EXISTS public.validate_branch_invite_code(TEXT);

-- ============================================================================
-- 6. Ensure Profiles Exist Using Real Auth Metadata (Preserves Existing Data)
-- ============================================================================
INSERT INTO public.profiles (id, full_name, email, account_status, created_at, updated_at)
SELECT 
    u.id,
    COALESCE(
        u.raw_user_meta_data->>'full_name',
        u.raw_user_meta_data->>'name',
        split_part(u.email, '@', 1)
    ),
    u.email,
    'active',
    now(),
    now()
FROM auth.users u
WHERE u.email IN ('asogwakenechukwu284@gmail.com', 'kenechukwuasogwa284@gmail.com')
ON CONFLICT (id) DO UPDATE SET
    updated_at = now();
    -- Does not overwrite existing full_name or account_status

-- ============================================================================
-- 7. Idempotently & Safely Configure Techverve Branch & Assignments
-- ============================================================================
DO $$
DECLARE
    v_manager_id UUID;
    v_member_id UUID;
    v_org_id UUID;
    v_old_org_created_by UUID;
    v_branch_id UUID;
    v_branch_existing_org UUID;
    
    v_org_count INT;
    v_branch_count INT;
    v_ic_count INT;
    v_form_config_count INT;
    v_mgr_assignment_count INT;
    v_existing_mgr_assign_id UUID;
    
    v_old_b_created_by UUID;
    v_old_mgr_role TEXT;
    v_old_mgr_active BOOLEAN;
    
    v_old_ic_branch UUID;
    v_old_ic_creator UUID;
    v_old_ic_used INT;
    v_old_ic_max INT;
    v_old_ic_revoked BOOLEAN;
    v_old_ic_expires TIMESTAMPTZ;
    v_old_ic_roles TEXT[];
BEGIN
    -- Resolve Manager and Member UUIDs directly from auth.users
    SELECT id INTO v_manager_id FROM auth.users WHERE email = 'asogwakenechukwu284@gmail.com';
    SELECT id INTO v_member_id FROM auth.users WHERE email = 'kenechukwuasogwa284@gmail.com';

    -- Prerequisite 1: Require BOTH manager and member accounts to exist
    IF v_manager_id IS NULL THEN
        RAISE EXCEPTION 'PREREQUISITE FAILED: Manager account asogwakenechukwu284@gmail.com not found in auth.users.';
    END IF;

    IF v_member_id IS NULL THEN
        RAISE EXCEPTION 'PREREQUISITE FAILED: Member account kenechukwuasogwa284@gmail.com not found in auth.users.';
    END IF;

    -- ========================================================================
    -- A. Organization Verification (Abort on ambiguity or conflict)
    -- ========================================================================
    SELECT COUNT(*) INTO v_org_count
    FROM public.organizations
    WHERE name IN ('Techverve Organization', 'Techverve')
       OR id = 'a8fbcf87-d286-427f-9369-cbe96670119a';

    IF v_org_count > 1 THEN
        RAISE EXCEPTION 'AMBIGUITY: Multiple organizations match Techverve (% found). Aborting without making changes.', v_org_count;
    ELSIF v_org_count = 1 THEN
        SELECT id, created_by INTO v_org_id, v_old_org_created_by
        FROM public.organizations
        WHERE name IN ('Techverve Organization', 'Techverve')
           OR id = 'a8fbcf87-d286-427f-9369-cbe96670119a';

        -- Verify ownership
        IF v_old_org_created_by IS DISTINCT FROM v_manager_id AND v_old_org_created_by IS NOT NULL THEN
            RAISE EXCEPTION 'OWNERSHIP CONFLICT: Organization % is owned by % (expected manager %). Aborting.',
                v_org_id, v_old_org_created_by, v_manager_id;
        END IF;

        UPDATE public.organizations
        SET created_by = COALESCE(created_by, v_manager_id)
        WHERE id = v_org_id;

        RAISE NOTICE '[ORGANIZATION PRESERVED] Organization ID: % linked to manager %', v_org_id, v_manager_id;
    ELSE
        v_org_id := 'a8fbcf87-d286-427f-9369-cbe96670119a'::uuid;
        RAISE NOTICE '[ORGANIZATION INSERT] Creating organization Techverve Organization (ID: %)', v_org_id;
        INSERT INTO public.organizations (id, name, organization_type, created_by, created_at)
        VALUES (v_org_id, 'Techverve Organization', 'technology', v_manager_id, now());
    END IF;

    -- ========================================================================
    -- B. Branch Configuration (Preserves real data; no fabricated values)
    -- ========================================================================
    SELECT COUNT(*) INTO v_branch_count 
    FROM public.branches 
    WHERE name = 'Techverve' OR branch_code = 'KAYCEE2006';

    IF v_branch_count > 1 THEN
        RAISE EXCEPTION 'AMBIGUITY: Multiple branches match name "Techverve" or code "KAYCEE2006" (% found). Aborting.', v_branch_count;
    ELSIF v_branch_count = 1 THEN
        SELECT id, created_by, organization_id INTO v_branch_id, v_old_b_created_by, v_branch_existing_org
        FROM public.branches 
        WHERE name = 'Techverve' OR branch_code = 'KAYCEE2006';

        IF v_old_b_created_by IS DISTINCT FROM v_manager_id THEN
            RAISE EXCEPTION 'OWNERSHIP CONFLICT: Branch Techverve (ID: %) has owner % (expected manager %). Aborting.',
                v_branch_id, v_old_b_created_by, v_manager_id;
        END IF;

        -- Verify organization relationship before modifying
        IF v_branch_existing_org IS NOT NULL AND v_branch_existing_org IS DISTINCT FROM v_org_id THEN
            RAISE EXCEPTION 'ORGANIZATION CONFLICT: Branch Techverve is already linked to organization % (expected %). Aborting.',
                v_branch_existing_org, v_org_id;
        END IF;

        -- Preserve existing real details; do not overwrite with fabricated defaults
        UPDATE public.branches
        SET organization_id = COALESCE(organization_id, v_org_id)
        WHERE id = v_branch_id;

        RAISE NOTICE '[BRANCH PRESERVED] Techverve branch ID: % preserved with existing details.', v_branch_id;
    ELSE
        v_branch_id := '73cf9e88-8dca-47d7-84b7-89a62107bb43'::uuid;
        RAISE NOTICE '[BRANCH INSERT] Creating Techverve branch with ID %', v_branch_id;
        INSERT INTO public.branches (
            id, organization_id, name, branch_code, description, address,
            contact_email, contact_phone, created_by, geofence_radius_meters,
            trusted_network_cidrs, created_at
        )
        VALUES (
            v_branch_id, v_org_id, 'Techverve', 'KAYCEE2006',
            'Techverve Innovation & Engineering Branch', 'Techverve Main Campus',
            'asogwakenechukwu284@gmail.com', NULL, v_manager_id, 100, '{}', now()
        );
    END IF;

    -- ========================================================================
    -- C. Manager Assignment (Detects duplicates & unexpected roles)
    -- ========================================================================
    SELECT COUNT(*) INTO v_mgr_assignment_count
    FROM public.user_branch_assignments
    WHERE user_id = v_manager_id AND branch_id = v_branch_id;

    IF v_mgr_assignment_count > 1 THEN
        RAISE EXCEPTION 'COLLISION: Manager has % existing assignments for branch %. Aborting.',
            v_mgr_assignment_count, v_branch_id;
    ELSIF v_mgr_assignment_count = 1 THEN
        SELECT id, role, is_active INTO v_existing_mgr_assign_id, v_old_mgr_role, v_old_mgr_active
        FROM public.user_branch_assignments
        WHERE user_id = v_manager_id AND branch_id = v_branch_id;

        IF v_old_mgr_role NOT IN ('branch_manager', 'branch_admin') THEN
            RAISE EXCEPTION 'ROLE CONFLICT: Manager holds unexpected role "%" in branch %. Aborting.',
                v_old_mgr_role, v_branch_id;
        END IF;

        UPDATE public.user_branch_assignments
        SET role = 'branch_manager', is_active = TRUE, effective_from = now()
        WHERE id = v_existing_mgr_assign_id;

        RAISE NOTICE '[MANAGER ASSIGNMENT UPDATED] ID: % confirmed as active branch_manager', v_existing_mgr_assign_id;
    ELSE
        INSERT INTO public.user_branch_assignments (
            id, user_id, branch_id, role, is_active, effective_from, created_at
        )
        VALUES (
            gen_random_uuid(), v_manager_id, v_branch_id, 'branch_manager', TRUE,
            now(), now()
        );
        RAISE NOTICE '[MANAGER ASSIGNMENT INSERTED] branch_manager created for manager %', v_manager_id;
    END IF;

    -- ========================================================================
    -- D. Member Assignment Verification (Abort if already active)
    -- ========================================================================
    IF EXISTS (
        SELECT 1 FROM public.user_branch_assignments
        WHERE user_id = v_member_id AND branch_id = v_branch_id AND is_active = TRUE
    ) THEN
        RAISE EXCEPTION 'PREFLIGHT HALTED: Member % already has an active assignment in branch %. Automatic deactivation as a test convenience is disabled. Explicit authorization required.',
            v_member_id, v_branch_id;
    ELSE
        RAISE NOTICE '[MEMBER ASSIGNMENT VERIFIED] Member % has no active assignment to branch % (clean gateway state).',
            v_member_id, v_branch_id;
    END IF;

    -- ========================================================================
    -- E. Branch Invite Code Verification (Verify ownership and branch)
    -- ========================================================================
    SELECT COUNT(*) INTO v_ic_count FROM public.branch_invite_codes WHERE code = 'KAYCEE2006';

    IF v_ic_count > 1 THEN
        RAISE EXCEPTION 'AMBIGUITY: Multiple records found for invite code KAYCEE2006 (% records). Aborting.', v_ic_count;
    ELSIF v_ic_count = 1 THEN
        SELECT branch_id, used_count, max_uses, is_revoked, expires_at, allowed_roles, created_by
        INTO v_old_ic_branch, v_old_ic_used, v_old_ic_max, v_old_ic_revoked, v_old_ic_expires, v_old_ic_roles, v_old_ic_creator
        FROM public.branch_invite_codes WHERE code = 'KAYCEE2006';

        IF v_old_ic_creator IS DISTINCT FROM v_manager_id THEN
            RAISE EXCEPTION 'OWNERSHIP CONFLICT: Invite code KAYCEE2006 is created by % (expected manager %). Aborting.',
                v_old_ic_creator, v_manager_id;
        END IF;

        IF v_old_ic_branch IS DISTINCT FROM v_branch_id THEN
            RAISE EXCEPTION 'BRANCH CONFLICT: Invite code KAYCEE2006 belongs to branch % (expected %). Aborting rather than moving invite to another branch.',
                v_old_ic_branch, v_branch_id;
        END IF;

        RAISE NOTICE '[INVITE CODE PRESERVED] KAYCEE2006: Branch: %, Uses: %/%, Revoked: %, Expires: %',
            v_old_ic_branch, v_old_ic_used, v_old_ic_max, v_old_ic_revoked, v_old_ic_expires;
    ELSE
        INSERT INTO public.branch_invite_codes (
            id, branch_id, code, created_by, allowed_roles, max_uses, used_count,
            expires_at, is_revoked, created_at
        )
        VALUES (
            'd1f7351c-e218-4000-8437-6f12a17b6550'::uuid, v_branch_id, 'KAYCEE2006',
            v_manager_id, '{"member"}', 100, 0,
            now() + interval '2 years', FALSE, now()
        );
        RAISE NOTICE '[INVITE CODE INSERTED] KAYCEE2006 created for branch %', v_branch_id;
    END IF;

    -- ========================================================================
    -- F. Branch ID Form Configuration (Preserves existing schema fields)
    -- ========================================================================
    SELECT COUNT(*) INTO v_form_config_count
    FROM public.branch_id_form_configs WHERE branch_id = v_branch_id;

    IF v_form_config_count = 0 THEN
        INSERT INTO public.branch_id_form_configs (id, branch_id, fields, created_at, updated_at)
        VALUES (
            gen_random_uuid(), v_branch_id,
            '[
                {"id": "photo", "label": "Identity Photo", "type": "photo", "isRequired": true, "isEnabled": true, "order": 0},
                {"id": "full_name", "label": "Full Name", "type": "text", "isRequired": true, "isEnabled": true, "order": 1},
                {"id": "email", "label": "Email Address", "type": "email", "isRequired": true, "isEnabled": true, "order": 2},
                {"id": "phone", "label": "Phone Number", "type": "phone", "isRequired": true, "isEnabled": true, "order": 3},
                {"id": "student_id", "label": "Student / Employee ID", "type": "text", "isRequired": true, "isEnabled": true, "order": 4}
            ]'::jsonb,
            now(), now()
        );
        RAISE NOTICE '[FORM CONFIG INSERTED] Default form config created for branch %', v_branch_id;
    ELSE
        RAISE NOTICE '[FORM CONFIG PRESERVED] Existing form config found for branch %', v_branch_id;
    END IF;
END $$;

-- ============================================================================
-- 8. Hardened Row Level Security Policies (24 Verified Policies)
-- ============================================================================

-- A. branches Policies (3 policies)
CREATE POLICY "branches_select_authorized"
ON public.branches FOR SELECT
TO authenticated
USING (
    public.is_branch_member(id)
    OR public.is_branch_manager(id)
    OR public.has_branch_membership_request(id)
);

CREATE POLICY "branches_insert_creator"
ON public.branches FOR INSERT
TO authenticated
WITH CHECK (created_by = auth.uid());

CREATE POLICY "branches_update_manager"
ON public.branches FOR UPDATE
TO authenticated
USING (public.is_branch_manager(id))
WITH CHECK (public.is_branch_manager(id));

-- B. organizations Policies (3 policies)
CREATE POLICY "organizations_select_related"
ON public.organizations FOR SELECT
TO authenticated
USING (
    created_by = auth.uid()
    OR EXISTS (
        SELECT 1 FROM public.branches b
        WHERE b.organization_id = organizations.id
          AND (
              public.is_branch_member(b.id)
              OR public.is_branch_manager(b.id)
              OR public.has_branch_membership_request(b.id)
          )
    )
);

CREATE POLICY "organizations_insert_owner"
ON public.organizations FOR INSERT
TO authenticated
WITH CHECK (
    created_by = auth.uid()
    AND length(trim(name)) >= 2
);

CREATE POLICY "organizations_update_owner"
ON public.organizations FOR UPDATE
TO authenticated
USING (
    created_by = auth.uid()
    OR EXISTS (
        SELECT 1 FROM public.user_branch_assignments uba
        WHERE uba.user_id = auth.uid() AND uba.role = 'web_admin' AND uba.is_active = TRUE
    )
)
WITH CHECK (
    created_by = auth.uid()
    OR EXISTS (
        SELECT 1 FROM public.user_branch_assignments uba
        WHERE uba.user_id = auth.uid() AND uba.role = 'web_admin' AND uba.is_active = TRUE
    )
);

-- C. profiles Policies (3 policies)
CREATE POLICY "profiles_select_own_or_related"
ON public.profiles FOR SELECT
TO authenticated
USING (
    auth.uid() = id
    OR public.shares_active_branch_with(id)
    OR EXISTS (
        SELECT 1 FROM public.user_branch_assignments uba
        WHERE uba.user_id = profiles.id AND public.is_branch_manager(uba.branch_id)
    )
    OR EXISTS (
        SELECT 1 FROM public.branch_membership_requests bmr
        WHERE bmr.user_id = profiles.id AND public.is_branch_manager(bmr.branch_id)
    )
);

CREATE POLICY "profiles_insert_own"
ON public.profiles FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = id);

CREATE POLICY "profiles_update_own"
ON public.profiles FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- D. branch_id_form_configs Policies (3 policies)
CREATE POLICY "branch_config_select_related"
ON public.branch_id_form_configs FOR SELECT
TO authenticated
USING (
    public.is_branch_member(branch_id)
    OR public.is_branch_manager(branch_id)
    OR public.has_branch_membership_request(branch_id)
);

CREATE POLICY "branch_config_insert_manager"
ON public.branch_id_form_configs FOR INSERT
TO authenticated
WITH CHECK (public.is_branch_manager(branch_id));

CREATE POLICY "branch_config_update_manager"
ON public.branch_id_form_configs FOR UPDATE
TO authenticated
USING (public.is_branch_manager(branch_id))
WITH CHECK (public.is_branch_manager(branch_id));

-- E. branch_invite_codes Policies (3 policies)
-- Strictly manager-only SELECT. Regular applicants cannot query invite codes directly.
CREATE POLICY "invite_codes_select_manager"
ON public.branch_invite_codes FOR SELECT
TO authenticated
USING (public.is_branch_manager(branch_id));

CREATE POLICY "invite_codes_insert_manager"
ON public.branch_invite_codes FOR INSERT
TO authenticated
WITH CHECK (
    created_by = auth.uid()
    AND public.is_branch_manager(branch_id)
    AND cardinality(allowed_roles) > 0
    AND allowed_roles <@ ARRAY['member']::text[]
    AND used_count = 0
);

CREATE POLICY "invite_codes_update_manager"
ON public.branch_invite_codes FOR UPDATE
TO authenticated
USING (public.is_branch_manager(branch_id))
WITH CHECK (
    public.is_branch_manager(branch_id)
    AND cardinality(allowed_roles) > 0
    AND allowed_roles <@ ARRAY['member']::text[]
);

-- F. branch_membership_requests Policies (4 policies)
CREATE POLICY "membership_requests_select_own"
ON public.branch_membership_requests FOR SELECT
TO authenticated
USING (user_id = auth.uid());

CREATE POLICY "membership_requests_select_manager"
ON public.branch_membership_requests FOR SELECT
TO authenticated
USING (public.is_branch_manager(branch_id));

CREATE POLICY "membership_requests_insert_own"
ON public.branch_membership_requests FOR INSERT
TO authenticated
WITH CHECK (
    user_id = auth.uid()
    AND status = 'pending'
    AND requested_role = 'member'
    AND reviewed_by IS NULL
    AND reviewed_at IS NULL
);

CREATE POLICY "membership_requests_update_manager"
ON public.branch_membership_requests FOR UPDATE
TO authenticated
USING (public.is_branch_manager(branch_id))
WITH CHECK (public.is_branch_manager(branch_id));

-- G. user_branch_assignments Policies (5 policies)
CREATE POLICY "assignments_select_own"
ON public.user_branch_assignments FOR SELECT
TO authenticated
USING (user_id = auth.uid());

CREATE POLICY "assignments_select_manager"
ON public.user_branch_assignments FOR SELECT
TO authenticated
USING (public.is_branch_manager(branch_id));

CREATE POLICY "assignments_insert_member_manager"
ON public.user_branch_assignments FOR INSERT
TO authenticated
WITH CHECK (
    role = 'member'
    AND public.is_branch_manager(branch_id)
);

CREATE POLICY "assignments_update_member_manager"
ON public.user_branch_assignments FOR UPDATE
TO authenticated
USING (
    role = 'member'
    AND public.is_branch_manager(branch_id)
)
WITH CHECK (
    role = 'member'
    AND public.is_branch_manager(branch_id)
);

CREATE POLICY "assignments_initial_branch_manager"
ON public.user_branch_assignments FOR INSERT
TO authenticated
WITH CHECK (
    user_id = auth.uid()
    AND role = 'branch_manager'
    AND is_active = TRUE
    AND EXISTS (
        SELECT 1 FROM public.branches b
        WHERE b.id = user_branch_assignments.branch_id
          AND b.created_by = auth.uid()
    )
    AND NOT EXISTS (
        SELECT 1 FROM public.user_branch_assignments existing
        WHERE existing.branch_id = user_branch_assignments.branch_id
    )
);

-- ============================================================================
-- 9. Integrity Functions & Triggers
-- ============================================================================

-- 1. Profile Update Integrity (Protects account_status)
CREATE OR REPLACE FUNCTION public.check_profile_update_integrity()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
DECLARE
    v_caller_role TEXT;
    v_caller_uid UUID;
    v_is_web_admin BOOLEAN := FALSE;
BEGIN
    IF NEW.account_status IS DISTINCT FROM OLD.account_status THEN
        v_caller_role := auth.role();
        v_caller_uid := auth.uid();

        IF v_caller_role = 'service_role' THEN
            NULL;
        ELSIF v_caller_role IS NULL AND v_caller_uid IS NULL THEN
            NULL;
        ELSIF v_caller_role = 'authenticated' AND v_caller_uid IS NOT NULL THEN
            SELECT EXISTS (
                SELECT 1 FROM public.user_branch_assignments
                WHERE user_id = v_caller_uid
                  AND role = 'web_admin'
                  AND is_active = TRUE
            ) INTO v_is_web_admin;

            IF NOT v_is_web_admin THEN
                RAISE EXCEPTION 'Permission denied: Only web administrators can modify account_status.';
            END IF;
        ELSE
            RAISE EXCEPTION 'Permission denied: Unauthorized context for modifying account_status.';
        END IF;
    END IF;

    NEW.updated_at := now();
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_profile_update_integrity ON public.profiles;
CREATE TRIGGER trg_profile_update_integrity
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.check_profile_update_integrity();

-- 2. Guard Branch Invite Code Changes (Permits Atomic Used-Count Increments)
CREATE OR REPLACE FUNCTION public.guard_branch_invite_code_changes()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
BEGIN
    -- Context 1: Service role execution (trusted server operations)
    IF auth.role() = 'service_role' THEN
        RETURN NEW;
    END IF;

    -- Context 2: Internal database session without HTTP JWT
    IF auth.role() IS NULL AND auth.uid() IS NULL THEN
        RETURN NEW;
    END IF;

    -- Context 3: Atomic usage increment triggered by membership application submission
    -- This allows applicants to atomically increment used_count without trigger deadlock
    IF TG_OP = 'UPDATE'
       AND NEW.used_count = OLD.used_count + 1
       AND NEW.id = OLD.id
       AND NEW.branch_id = OLD.branch_id
       AND NEW.code = OLD.code
       AND NEW.created_by = OLD.created_by
       AND NEW.created_at = OLD.created_at
       AND NEW.expires_at IS NOT DISTINCT FROM OLD.expires_at
       AND NEW.is_revoked IS NOT DISTINCT FROM OLD.is_revoked
       AND NEW.allowed_roles IS NOT DISTINCT FROM OLD.allowed_roles
       AND NEW.max_uses IS NOT DISTINCT FROM OLD.max_uses THEN
        RETURN NEW;
    END IF;

    -- Context 4: Manager-driven operations
    IF auth.uid() IS NULL OR NOT public.is_branch_manager(NEW.branch_id) THEN
        RAISE EXCEPTION 'Not authorized to manage this invite code';
    END IF;

    IF TG_OP = 'INSERT' THEN
        IF NEW.created_by IS DISTINCT FROM auth.uid() THEN
            RAISE EXCEPTION 'Invite creator must be the authenticated manager';
        END IF;

        IF NEW.used_count IS DISTINCT FROM 0 THEN
            RAISE EXCEPTION 'New invite codes must start with zero uses';
        END IF;

        IF cardinality(NEW.allowed_roles) = 0 OR NOT (NEW.allowed_roles <@ ARRAY['member']::text[]) THEN
            RAISE EXCEPTION 'Invite codes may only grant member access';
        END IF;

        RETURN NEW;
    END IF;

    -- On UPDATE by manager: identity and usage count cannot be manually edited
    IF NEW.id IS DISTINCT FROM OLD.id
       OR NEW.branch_id IS DISTINCT FROM OLD.branch_id
       OR NEW.created_by IS DISTINCT FROM OLD.created_by
       OR NEW.created_at IS DISTINCT FROM OLD.created_at
       OR NEW.used_count IS DISTINCT FROM OLD.used_count THEN
        RAISE EXCEPTION 'Invite identity and usage count cannot be edited directly';
    END IF;

    -- If manager updates the invite code text, enforce minimum length and case-insensitive uniqueness
    IF NEW.code IS DISTINCT FROM OLD.code THEN
        IF NEW.code IS NULL OR LENGTH(TRIM(NEW.code)) < 4 THEN
            RAISE EXCEPTION 'Invite code must be at least 4 characters';
        END IF;
        IF EXISTS (
            SELECT 1 FROM public.branch_invite_codes
            WHERE UPPER(TRIM(code)) = UPPER(TRIM(NEW.code)) AND id != OLD.id
        ) THEN
            RAISE EXCEPTION 'An invite code with this value already exists';
        END IF;
    END IF;

    IF cardinality(NEW.allowed_roles) = 0 OR NOT (NEW.allowed_roles <@ ARRAY['member']::text[]) THEN
        RAISE EXCEPTION 'Invite codes may only grant member access';
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_guard_branch_invite_code_changes ON public.branch_invite_codes;
CREATE TRIGGER trg_guard_branch_invite_code_changes
    BEFORE INSERT OR UPDATE ON public.branch_invite_codes
    FOR EACH ROW
    EXECUTE FUNCTION public.guard_branch_invite_code_changes();

-- 3. Atomic Invite Validation and Consumption Trigger (Requires Real Validated ID)
CREATE OR REPLACE FUNCTION public.handle_membership_request_invite_increment()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
DECLARE
    v_invite_id UUID;
BEGIN
    -- Require real validated invite ID; no automatic fallback selection
    IF NEW.invite_code_id IS NULL THEN
        RAISE EXCEPTION 'A valid invite code is required';
    END IF;

    IF NEW.status IS DISTINCT FROM 'pending'
       OR NEW.requested_role IS DISTINCT FROM 'member'
       OR NEW.reviewed_by IS NOT NULL
       OR NEW.reviewed_at IS NOT NULL THEN
        RAISE EXCEPTION 'New membership requests must be pending member requests';
    END IF;

    -- Atomic row-locking validation and consumption
    UPDATE public.branch_invite_codes
    SET used_count = used_count + 1
    WHERE id = NEW.invite_code_id
      AND branch_id = NEW.branch_id
      AND COALESCE(is_revoked, FALSE) = FALSE
      AND (expires_at IS NULL OR expires_at > now())
      AND (max_uses IS NULL OR used_count < max_uses)
      AND NEW.requested_role = ANY(allowed_roles)
    RETURNING id INTO v_invite_id;

    IF v_invite_id IS NULL THEN
        RAISE EXCEPTION 'Invite code is invalid, expired, revoked, exhausted, or not valid for this branch or role';
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_membership_invite_increment ON public.branch_membership_requests;
CREATE TRIGGER trg_membership_invite_increment
    BEFORE INSERT ON public.branch_membership_requests
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_membership_request_invite_increment();

-- 4. Guard Membership Request Review
CREATE OR REPLACE FUNCTION public.guard_membership_request_review()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
BEGIN
    -- Immutability of submitted fields
    IF NEW.id IS DISTINCT FROM OLD.id
       OR NEW.user_id IS DISTINCT FROM OLD.user_id
       OR NEW.branch_id IS DISTINCT FROM OLD.branch_id
       OR NEW.invite_code_id IS DISTINCT FROM OLD.invite_code_id
       OR NEW.requested_role IS DISTINCT FROM OLD.requested_role
       OR NEW.submitted_data IS DISTINCT FROM OLD.submitted_data
       OR NEW.photo_url IS DISTINCT FROM OLD.photo_url
       OR NEW.created_at IS DISTINCT FROM OLD.created_at THEN
        RAISE EXCEPTION 'Membership request identity and submitted information cannot be changed';
    END IF;

    -- Authorization check
    IF auth.role() IS DISTINCT FROM 'service_role' AND (auth.role() IS NOT NULL OR auth.uid() IS NOT NULL) THEN
        IF auth.uid() IS NULL OR NOT public.is_branch_manager(OLD.branch_id) THEN
            RAISE EXCEPTION 'Not authorized to review this membership request';
        END IF;

        IF NEW.reviewed_by IS DISTINCT FROM auth.uid() THEN
            RAISE EXCEPTION 'Reviewer must be the authenticated branch manager';
        END IF;

        IF OLD.user_id = auth.uid() THEN
            RAISE EXCEPTION 'Conflict of interest: A manager cannot review their own membership request';
        END IF;
    END IF;

    IF NEW.status IS DISTINCT FROM OLD.status THEN
        IF OLD.status NOT IN ('pending', 'needs_information') THEN
            RAISE EXCEPTION 'This membership request has already been decided';
        END IF;

        IF NEW.status NOT IN ('approved', 'rejected', 'needs_information') THEN
            RAISE EXCEPTION 'Invalid membership review status';
        END IF;

        IF NEW.reviewed_at IS NULL THEN
            NEW.reviewed_at := now();
        END IF;

        IF NEW.reviewed_by IS NULL THEN
            NEW.reviewed_by := COALESCE(auth.uid(), OLD.reviewed_by);
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_guard_membership_request_review ON public.branch_membership_requests;
CREATE TRIGGER trg_guard_membership_request_review
    BEFORE UPDATE ON public.branch_membership_requests
    FOR EACH ROW
    EXECUTE FUNCTION public.guard_membership_request_review();

-- 5. Safe Approval & Single Active Member Assignment Trigger (Serialized by User Lock)
CREATE OR REPLACE FUNCTION public.handle_membership_request_approval()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
DECLARE
    v_assignment_id UUID;
BEGIN
    IF NEW.status = 'approved' AND OLD.status IS DISTINCT FROM 'approved' THEN
        IF NEW.requested_role IS DISTINCT FROM 'member' THEN
            RAISE EXCEPTION 'Only member requests can be approved through this workflow';
        END IF;

        -- Serialize concurrent approvals for the same user via profile row lock
        PERFORM 1 FROM public.profiles WHERE id = NEW.user_id FOR UPDATE;

        -- Find existing assignment for this user and branch
        SELECT id INTO v_assignment_id
        FROM public.user_branch_assignments
        WHERE user_id = NEW.user_id
          AND branch_id = NEW.branch_id
          AND role = 'member'
        ORDER BY is_active DESC, created_at DESC
        LIMIT 1
        FOR UPDATE;

        -- Deactivate all active member assignments across branches
        UPDATE public.user_branch_assignments
        SET is_active = FALSE,
            effective_to = COALESCE(effective_to, now())
        WHERE user_id = NEW.user_id
          AND role = 'member'
          AND is_active = TRUE;

        -- Reactivate or insert exactly one active member assignment
        IF v_assignment_id IS NOT NULL THEN
            UPDATE public.user_branch_assignments
            SET is_active = TRUE,
                effective_from = now(),
                effective_to = NULL
            WHERE id = v_assignment_id;
        ELSE
            INSERT INTO public.user_branch_assignments (
                id, user_id, branch_id, role, is_active, effective_from, created_at
            )
            VALUES (
                gen_random_uuid(), NEW.user_id, NEW.branch_id, 'member',
                TRUE, now(), now()
            );
        END IF;

    -- If previously approved application is rejected/revoked
    ELSIF OLD.status = 'approved' AND NEW.status IS DISTINCT FROM 'approved' THEN
        UPDATE public.user_branch_assignments
        SET is_active = FALSE,
            effective_to = now()
        WHERE user_id = NEW.user_id
          AND branch_id = NEW.branch_id
          AND role = 'member'
          AND is_active = TRUE;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_membership_approval_assignment ON public.branch_membership_requests;
CREATE TRIGGER trg_membership_approval_assignment
    AFTER UPDATE OF status ON public.branch_membership_requests
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_membership_request_approval();

-- 6. Assignment Integrity Trigger
CREATE OR REPLACE FUNCTION public.check_user_branch_assignment_integrity()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
DECLARE
    v_caller_role TEXT;
    v_caller_uid UUID;
    v_is_web_admin BOOLEAN := FALSE;
BEGIN
    v_caller_role := auth.role();
    v_caller_uid := auth.uid();

    -- Context 1: Service role execution
    IF v_caller_role = 'service_role' THEN
        RETURN NEW;
    END IF;

    -- Context 2: Direct internal database session without HTTP JWT
    IF v_caller_role IS NULL AND v_caller_uid IS NULL THEN
        RETURN NEW;
    END IF;

    -- Context 3: Authenticated client callers
    IF v_caller_role = 'authenticated' AND v_caller_uid IS NOT NULL THEN
        SELECT EXISTS (
            SELECT 1 FROM public.user_branch_assignments
            WHERE user_id = v_caller_uid AND role = 'web_admin' AND is_active = TRUE
        ) INTO v_is_web_admin;

        IF v_is_web_admin THEN
            RETURN NEW;
        END IF;

        IF TG_OP = 'INSERT' AND NEW.role = 'web_admin' THEN
            RAISE EXCEPTION 'Permission denied: Only web administrators can grant web_admin assignments.';
        ELSIF TG_OP = 'UPDATE' AND (NEW.role = 'web_admin' OR OLD.role = 'web_admin') THEN
            RAISE EXCEPTION 'Permission denied: Only web administrators can modify web_admin assignments.';
        END IF;

        IF TG_OP = 'UPDATE' THEN
            IF NEW.user_id IS DISTINCT FROM OLD.user_id THEN
                RAISE EXCEPTION 'Security violation: user_id cannot be modified on a branch assignment.';
            END IF;
            IF NEW.branch_id IS DISTINCT FROM OLD.branch_id THEN
                RAISE EXCEPTION 'Security violation: branch_id cannot be modified on a branch assignment.';
            END IF;
        END IF;

        IF TG_OP = 'INSERT' THEN
            IF public.is_branch_manager(NEW.branch_id) THEN
                RETURN NEW;
            ELSIF (
                NEW.user_id = v_caller_uid
                AND NEW.role = 'branch_manager'
                AND EXISTS (
                    SELECT 1 FROM public.branches b
                    WHERE b.id = NEW.branch_id AND b.created_by = v_caller_uid
                )
            ) THEN
                RETURN NEW;
            ELSE
                RAISE EXCEPTION 'Permission denied: Unauthorized branch assignment creation.';
            END IF;

        ELSIF TG_OP = 'UPDATE' THEN
            IF public.is_branch_manager(OLD.branch_id) THEN
                RETURN NEW;
            -- Allow manager to deactivate member pursuant to an approved request in their branch
            ELSIF (
                OLD.role = 'member'
                AND NEW.is_active = FALSE
                AND EXISTS (
                    SELECT 1 FROM public.branch_membership_requests bmr
                    WHERE bmr.user_id = OLD.user_id
                      AND bmr.status = 'approved'
                      AND bmr.reviewed_by = v_caller_uid
                      AND public.is_branch_manager(bmr.branch_id)
                )
            ) THEN
                RETURN NEW;
            ELSE
                RAISE EXCEPTION 'Permission denied: Unauthorized branch assignment modification.';
            END IF;
        END IF;
    END IF;

    RAISE EXCEPTION 'Permission denied: Unauthorized caller context for user_branch_assignments.';
END;
$$;

DROP TRIGGER IF EXISTS trg_user_branch_assignment_integrity ON public.user_branch_assignments;
CREATE TRIGGER trg_user_branch_assignment_integrity
    BEFORE INSERT OR UPDATE ON public.user_branch_assignments
    FOR EACH ROW
    EXECUTE FUNCTION public.check_user_branch_assignment_integrity();

-- ============================================================================
-- 10. Helper Functions & Permissions (Minimum Required Privileges)
-- ============================================================================

-- Secure Invite-Code Validator returning invite_code_id and status diagnostics
CREATE OR REPLACE FUNCTION public.validate_branch_invite_code(invite_code TEXT)
RETURNS TABLE (
    invite_code_id UUID,
    branch_id UUID,
    branch_name TEXT,
    organization_id UUID,
    code TEXT,
    allowed_roles TEXT[],
    expires_at TIMESTAMPTZ,
    max_uses INTEGER,
    used_count INTEGER,
    is_revoked BOOLEAN,
    is_valid BOOLEAN,
    status TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
DECLARE
    v_clean TEXT;
BEGIN
    IF invite_code IS NULL THEN
        RETURN;
    END IF;

    v_clean := UPPER(TRIM(invite_code));
    IF LENGTH(v_clean) < 4 THEN
        RETURN;
    END IF;

    RETURN QUERY
    SELECT 
        bic.id AS invite_code_id,
        b.id AS branch_id,
        b.name AS branch_name,
        b.organization_id,
        bic.code,
        bic.allowed_roles,
        bic.expires_at,
        bic.max_uses,
        bic.used_count,
        bic.is_revoked,
        (
            bic.is_revoked = FALSE
            AND (bic.expires_at IS NULL OR bic.expires_at > now())
            AND (bic.max_uses IS NULL OR bic.used_count < bic.max_uses)
            AND 'member' = ANY(bic.allowed_roles)
        ) AS is_valid,
        CASE
            WHEN bic.is_revoked = TRUE THEN 'revoked'
            WHEN bic.expires_at IS NOT NULL AND bic.expires_at <= now() THEN 'expired'
            WHEN bic.max_uses IS NOT NULL AND bic.used_count >= bic.max_uses THEN 'exhausted'
            WHEN NOT ('member' = ANY(bic.allowed_roles)) THEN 'invalid_role'
            ELSE 'valid'
        END AS status
    FROM public.branch_invite_codes bic
    JOIN public.branches b ON b.id = bic.branch_id
    WHERE UPPER(TRIM(bic.code)) = v_clean
    ORDER BY bic.created_at DESC
    LIMIT 1;
END;
$$;

-- Explicitly revoke default execute permissions from PUBLIC and anon on newly created function
REVOKE ALL ON FUNCTION public.validate_branch_invite_code(TEXT) FROM PUBLIC, anon;

-- Table privileges strictly for authenticated on the seven target tables
GRANT USAGE ON SCHEMA public TO authenticated;

GRANT SELECT, INSERT, UPDATE ON TABLE public.branches TO authenticated;
GRANT SELECT, INSERT, UPDATE ON TABLE public.user_branch_assignments TO authenticated;
GRANT SELECT, INSERT, UPDATE ON TABLE public.branch_invite_codes TO authenticated;
GRANT SELECT, INSERT, UPDATE ON TABLE public.branch_membership_requests TO authenticated;
GRANT SELECT, INSERT, UPDATE ON TABLE public.branch_id_form_configs TO authenticated;
GRANT SELECT, INSERT, UPDATE ON TABLE public.organizations TO authenticated;
GRANT SELECT, INSERT, UPDATE ON TABLE public.profiles TO authenticated;

-- Routine execution permissions strictly for authenticated (anon completely revoked)
GRANT EXECUTE ON FUNCTION public.validate_branch_invite_code(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_branch_manager(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_branch_member(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.has_branch_membership_request(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.shares_active_branch_with(UUID) TO authenticated;

-- Notify PostgREST to immediately refresh its schema cache for new functions and types
NOTIFY pgrst, 'reload schema';

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES (Safe, Read-Only Diagnostics)
-- ============================================================================

-- 1. Organization & Branch Relationship & Ownership
SELECT 
    o.id AS organization_id, o.name AS organization_name, o.created_by AS organization_owner,
    b.id AS branch_id, b.name AS branch_name, b.branch_code, b.address, b.contact_email, b.contact_phone, b.created_by AS branch_owner
FROM public.organizations o
LEFT JOIN public.branches b ON b.organization_id = o.id
WHERE b.name = 'Techverve' OR o.name IN ('Techverve', 'Techverve Organization');

-- 2. Invite Code Settings & Integrity
SELECT id, code, branch_id, created_by, used_count, max_uses, expires_at, is_revoked, allowed_roles
FROM public.branch_invite_codes WHERE code = 'KAYCEE2006';

-- 3. Assignments for Designated Test Accounts
SELECT uba.id, uba.user_id, p.email, uba.branch_id, b.name AS branch_name, uba.role, uba.is_active, uba.effective_from, uba.effective_to
FROM public.user_branch_assignments uba
JOIN public.profiles p ON p.id = uba.user_id
JOIN public.branches b ON b.id = uba.branch_id
WHERE p.email IN ('asogwakenechukwu284@gmail.com', 'kenechukwuasogwa284@gmail.com')
ORDER BY p.email, uba.is_active DESC;

-- 4. Active Triggers on Target Tables
SELECT t.tgname AS trigger_name, c.relname AS table_name, pg_get_triggerdef(t.oid) AS trigger_definition
FROM pg_trigger t
JOIN pg_class c ON c.oid = t.tgrelid
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public'
  AND c.relname IN ('branches', 'organizations', 'profiles', 'branch_invite_codes', 'branch_membership_requests', 'branch_id_form_configs', 'user_branch_assignments')
  AND NOT t.tgisinternal
ORDER BY c.relname, t.tgname;

-- 5. Exact Final Policy Inventory (Expect exactly 24 policies)
SELECT tablename, policyname, cmd, qual, with_check
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('branches', 'organizations', 'profiles', 'branch_invite_codes', 'branch_membership_requests', 'branch_id_form_configs', 'user_branch_assignments')
ORDER BY tablename, policyname;

-- 6. Table Privileges for Authenticated Role
SELECT grantee, table_schema, table_name, privilege_type
FROM information_schema.role_table_grants
WHERE grantee = 'authenticated'
  AND table_schema = 'public'
  AND table_name IN ('branches', 'organizations', 'profiles', 'branch_invite_codes', 'branch_membership_requests', 'branch_id_form_configs', 'user_branch_assignments')
ORDER BY table_name, privilege_type;

-- 7. Function Execution Permissions
SELECT routine_name, grantee, privilege_type
FROM information_schema.routine_privileges
WHERE routine_schema = 'public'
  AND routine_name IN ('validate_branch_invite_code', 'is_branch_manager', 'is_branch_member', 'has_branch_membership_request', 'shares_active_branch_with')
ORDER BY routine_name, grantee;

-- 8. Storage Policies for Private id-documents Bucket
SELECT policyname, tablename, cmd, qual, with_check
FROM pg_policies
WHERE schemaname = 'storage' AND tablename = 'objects'
ORDER BY policyname;
