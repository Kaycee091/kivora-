-- ============================================================================
-- 00008_techverve_test_setup.sql
-- Production-Hardened, Transaction-Safe, Non-Destructive Techverve Migration
-- (Exact match to 00008_techverve_test_setup_FINAL.sql)
-- ============================================================================

BEGIN;

-- 1. Enforce Row Level Security on All Seven Target Tables
ALTER TABLE public.branches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_branch_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.branch_invite_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.branch_membership_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.branch_id_form_configs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 2. Revoke Broad Default Privileges from PUBLIC and anon
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
REVOKE ALL ON FUNCTION public.validate_branch_invite_code(TEXT) FROM public;

-- 3. Ensure Public Profiles Exist (Preserves existing account_status)
INSERT INTO public.profiles (id, full_name, email, account_status, created_at, updated_at)
SELECT 
    u.id,
    CASE 
        WHEN u.email = 'asogwakenechukwu284@gmail.com' THEN 'Kenechukwu Asogwa (Manager)'
        ELSE 'Kenechukwu Asogwa (Member)'
    END,
    u.email,
    'active',
    now(),
    now()
FROM auth.users u
WHERE u.email IN ('asogwakenechukwu284@gmail.com', 'kenechukwuasogwa284@gmail.com')
ON CONFLICT (id) DO UPDATE SET
    updated_at = now();

-- Ensure created_by column exists on organizations for ownership tracking
ALTER TABLE public.organizations 
ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES public.profiles(id);

-- 4. Idempotently & Deterministically Configure Techverve Branch & Assignments
DO $$
DECLARE
    v_manager_id UUID;
    v_member_id UUID;
    v_org_id UUID;
    v_old_org_created_by UUID;
    v_branch_id UUID;
    
    v_org_count INT;
    v_branch_count INT;
    v_ic_count INT;
    v_form_config_count INT;
    v_mgr_assignment_count INT;
    v_existing_mgr_assign_id UUID;
    
    -- Variables for explicit before/after change logging
    v_old_b_name TEXT;
    v_old_b_code TEXT;
    v_old_b_address TEXT;
    v_old_b_email TEXT;
    v_old_b_phone TEXT;
    v_old_b_desc TEXT;
    v_old_b_created_by UUID;
    
    v_old_mgr_role TEXT;
    v_old_mgr_active BOOLEAN;
    
    v_old_mem_role TEXT;
    v_old_mem_active BOOLEAN;
    
    v_old_ic_branch UUID;
    v_old_ic_creator UUID;
    v_old_ic_used INT;
    v_old_ic_max INT;
    v_old_ic_revoked BOOLEAN;
    v_old_ic_expires TIMESTAMPTZ;
    v_old_ic_roles TEXT[];
BEGIN
    SELECT id INTO v_manager_id FROM auth.users WHERE email = 'asogwakenechukwu284@gmail.com';
    SELECT id INTO v_member_id FROM auth.users WHERE email = 'kenechukwuasogwa284@gmail.com';

    IF v_manager_id IS NULL THEN
        RAISE EXCEPTION 'PREREQUISITE FAILED: Manager account asogwakenechukwu284@gmail.com not found in auth.users.';
    END IF;

    IF v_member_id IS NULL THEN
        RAISE EXCEPTION 'PREREQUISITE FAILED: Member account kenechukwuasogwa284@gmail.com not found in auth.users.';
    END IF;

    -- Preflight collision & ambiguity checks
    IF EXISTS (
        SELECT 1 FROM public.branch_invite_codes
        WHERE code = 'KAYCEE2006'
          AND created_by IS DISTINCT FROM v_manager_id
    ) THEN
        RAISE EXCEPTION 'COLLISION: Invitation code KAYCEE2006 is owned by a different creator or has NULL creator. Aborting.';
    END IF;

    IF EXISTS (
        SELECT 1 FROM public.branches
        WHERE (name = 'Techverve' OR branch_code = 'KAYCEE2006')
          AND created_by IS DISTINCT FROM v_manager_id
    ) THEN
        RAISE EXCEPTION 'COLLISION: Branch Techverve or code KAYCEE2006 is owned by another user or has NULL owner. Aborting without transferring ownership.';
    END IF;

    SELECT COUNT(*) INTO v_ic_count
    FROM public.branch_invite_codes
    WHERE code = 'KAYCEE2006';

    IF v_ic_count > 1 THEN
        RAISE EXCEPTION 'AMBIGUITY: Multiple records found for invite code "KAYCEE2006" (% records). Aborting.', v_ic_count;
    END IF;

    SELECT COUNT(*) INTO v_branch_count
    FROM public.branches
    WHERE name = 'Techverve' OR branch_code = 'KAYCEE2006';

    IF v_branch_count > 1 THEN
        RAISE EXCEPTION 'AMBIGUITY: Multiple branches match name "Techverve" or code "KAYCEE2006" (% branches found). Aborting without making changes.', v_branch_count;
    ELSIF v_branch_count = 1 THEN
        SELECT id, created_by INTO v_branch_id, v_old_b_created_by
        FROM public.branches
        WHERE name = 'Techverve' OR branch_code = 'KAYCEE2006';

        IF v_old_b_created_by IS DISTINCT FROM v_manager_id THEN
            RAISE EXCEPTION 'OWNERSHIP CONFLICT: Branch Techverve (ID: %) has owner % (expected manager %). Aborting without automatic ownership transfer.',
                v_branch_id, v_old_b_created_by, v_manager_id;
        END IF;
    ELSE
        v_branch_id := NULL;
    END IF;

    IF EXISTS (
        SELECT 1 FROM public.branch_invite_codes
        WHERE code = 'KAYCEE2006'
          AND v_branch_id IS NOT NULL
          AND branch_id IS DISTINCT FROM v_branch_id
    ) THEN
        RAISE EXCEPTION 'COLLISION: Invitation code KAYCEE2006 is already attached to a different branch. Aborting rather than repointing.';
    END IF;

    -- A. Organization Verification & Creation
    SELECT COUNT(*) INTO v_org_count
    FROM public.organizations
    WHERE name = 'Techverve Organization';

    IF v_org_count > 1 THEN
        RAISE EXCEPTION 'AMBIGUITY: Multiple organizations found matching "Techverve Organization" (% found). Aborting.', v_org_count;
    ELSIF v_org_count = 1 THEN
        SELECT id, created_by INTO v_org_id, v_old_org_created_by
        FROM public.organizations
        WHERE name = 'Techverve Organization';

        IF v_old_org_created_by IS DISTINCT FROM v_manager_id THEN
            RAISE EXCEPTION 'OWNERSHIP CONFLICT: Organization "Techverve Organization" (ID: %) is owned by % (expected manager %). Aborting on foreign/unassigned owner.',
                v_org_id, v_old_org_created_by, v_manager_id;
        ELSE
            RAISE NOTICE '[ORGANIZATION PRESERVED] Existing organization "Techverve Organization" verified for manager % (ID: %). Preserving.',
                v_manager_id, v_org_id;
        END IF;
    ELSE
        v_org_id := gen_random_uuid();
        RAISE NOTICE '[ORGANIZATION INSERT] Creating new organization "Techverve Organization" (ID: %) owned by manager %', v_org_id, v_manager_id;
        INSERT INTO public.organizations (id, name, organization_type, created_by, created_at)
        VALUES (v_org_id, 'Techverve Organization', 'technology', v_manager_id, timezone('utc', now()));
    END IF;

    -- B. Branch Configuration
    IF v_branch_id IS NOT NULL THEN
        SELECT name, branch_code, address, contact_email, contact_phone, description, created_by
        INTO v_old_b_name, v_old_b_code, v_old_b_address, v_old_b_email, v_old_b_phone, v_old_b_desc, v_old_b_created_by
        FROM public.branches WHERE id = v_branch_id;

        RAISE NOTICE '[BRANCH UPDATE] Branch ID: % | Name: Techverve, Code: KAYCEE2006 | Preserving existing contact and address details.',
            v_branch_id;

        UPDATE public.branches
        SET 
            name = 'Techverve',
            branch_code = 'KAYCEE2006',
            organization_id = COALESCE(organization_id, v_org_id),
            description = COALESCE(description, 'Techverve Innovation & Engineering Branch'),
            address = COALESCE(address, 'Techverve Main Campus'),
            contact_email = COALESCE(contact_email, 'asogwakenechukwu284@gmail.com'),
            contact_phone = COALESCE(contact_phone, v_old_b_phone)
        WHERE id = v_branch_id;
    ELSE
        v_branch_id := gen_random_uuid();
        RAISE NOTICE '[BRANCH INSERT] Creating new Techverve branch with ID % (Owned by manager %)', v_branch_id, v_manager_id;
        INSERT INTO public.branches (
            id,
            organization_id,
            name,
            branch_code,
            description,
            address,
            contact_email,
            contact_phone,
            created_by,
            geofence_radius_meters,
            trusted_network_cidrs,
            created_at
        )
        VALUES (
            v_branch_id,
            v_org_id,
            'Techverve',
            'KAYCEE2006',
            'Techverve Innovation & Engineering Branch',
            'Techverve Main Campus',
            'asogwakenechukwu284@gmail.com',
            NULL,
            v_manager_id,
            100,
            '{}',
            timezone('utc', now())
        );
    END IF;

    -- C. Manager Assignment
    SELECT COUNT(*) INTO v_mgr_assignment_count
    FROM public.user_branch_assignments
    WHERE user_id = v_manager_id AND branch_id = v_branch_id;

    IF v_mgr_assignment_count > 1 THEN
        RAISE EXCEPTION 'COLLISION: Manager has % existing assignments for branch %. Aborting to prevent silent consolidation.',
            v_mgr_assignment_count, v_branch_id;
    ELSIF v_mgr_assignment_count = 1 THEN
        SELECT id, role, is_active INTO v_existing_mgr_assign_id, v_old_mgr_role, v_old_mgr_active
        FROM public.user_branch_assignments
        WHERE user_id = v_manager_id AND branch_id = v_branch_id;

        IF v_old_mgr_role NOT IN ('branch_manager', 'branch_admin') THEN
            RAISE EXCEPTION 'ROLE CONFLICT: Manager holds unexpected role "%" in branch %. Aborting rather than silently converting unrelated role.',
                v_old_mgr_role, v_branch_id;
        END IF;

        RAISE NOTICE '[MANAGER ASSIGNMENT UPDATE] Updating assignment ID % (Role: %, Active: %) -> (Role: branch_manager, Active: TRUE)',
            v_existing_mgr_assign_id, v_old_mgr_role, v_old_mgr_active;

        UPDATE public.user_branch_assignments
        SET 
            role = 'branch_manager',
            is_active = TRUE,
            effective_from = timezone('utc', now())
        WHERE id = v_existing_mgr_assign_id;
    ELSE
        RAISE NOTICE '[MANAGER ASSIGNMENT INSERT] Creating branch_manager assignment for manager % in branch %',
            v_manager_id, v_branch_id;

        INSERT INTO public.user_branch_assignments (
            id,
            user_id,
            branch_id,
            role,
            is_active,
            effective_from,
            created_at
        )
        VALUES (
            gen_random_uuid(),
            v_manager_id,
            v_branch_id,
            'branch_manager',
            TRUE,
            timezone('utc', now()),
            timezone('utc', now())
        );
    END IF;

    -- D. Member Clean Gateway Testing Entry
    IF EXISTS (
        SELECT 1 FROM public.user_branch_assignments
        WHERE user_id = v_member_id AND branch_id = v_branch_id AND role = 'member'
    ) THEN
        SELECT role, is_active INTO v_old_mem_role, v_old_mem_active
        FROM public.user_branch_assignments
        WHERE user_id = v_member_id AND branch_id = v_branch_id AND role = 'member';

        RAISE NOTICE '[MEMBER ASSIGNMENT UPDATE] Member ID: % | Setting is_active = FALSE for fresh gateway onboarding test',
            v_member_id;

        UPDATE public.user_branch_assignments
        SET is_active = FALSE
        WHERE user_id = v_member_id AND branch_id = v_branch_id AND role = 'member';
    ELSE
        RAISE NOTICE '[MEMBER ASSIGNMENT] Member % has no prior assignment to Techverve (Preserved unassigned state).', v_member_id;
    END IF;

    -- E. Branch Invite Code
    IF v_ic_count = 1 THEN
        SELECT branch_id, used_count, max_uses, is_revoked, expires_at, allowed_roles, created_by
        INTO v_old_ic_branch, v_old_ic_used, v_old_ic_max, v_old_ic_revoked, v_old_ic_expires, v_old_ic_roles, v_old_ic_creator
        FROM public.branch_invite_codes WHERE code = 'KAYCEE2006';

        RAISE NOTICE '[INVITE CODE PRESERVED] KAYCEE2006: Branch: %, Uses: %/%, Revoked: %, Expires: %, Roles: %',
            v_old_ic_branch, v_old_ic_used, v_old_ic_max, v_old_ic_revoked, v_old_ic_expires, v_old_ic_roles;

        IF v_old_ic_revoked = TRUE THEN
            RAISE NOTICE '[INVITE CODE STATUS] KAYCEE2006 is REVOKED. Preserving revoked state without automatic un-revocation.';
        END IF;

        IF v_old_ic_expires <= timezone('utc', now()) THEN
            RAISE NOTICE '[INVITE CODE STATUS] KAYCEE2006 is EXPIRED (Expires: %). Preserving expired timestamp without automatic extension.',
                v_old_ic_expires;
        END IF;

        UPDATE public.branch_invite_codes
        SET 
            created_by = COALESCE(created_by, v_manager_id)
        WHERE code = 'KAYCEE2006';
    ELSE
        RAISE NOTICE '[INVITE CODE INSERT] Creating fresh invite code KAYCEE2006 for branch % (used_count: 0, max_uses: 100, valid for 2 years)', v_branch_id;

        INSERT INTO public.branch_invite_codes (
            id,
            branch_id,
            code,
            created_by,
            allowed_roles,
            max_uses,
            used_count,
            expires_at,
            is_revoked,
            created_at
        )
        VALUES (
            gen_random_uuid(),
            v_branch_id,
            'KAYCEE2006',
            v_manager_id,
            '{"member"}',
            100,
            0,
            timezone('utc', now()) + interval '2 years',
            FALSE,
            timezone('utc', now())
        );
    END IF;

    -- F. Branch ID Form Configuration
    SELECT COUNT(*) INTO v_form_config_count
    FROM public.branch_id_form_configs
    WHERE branch_id = v_branch_id;

    IF v_form_config_count > 1 THEN
        RAISE EXCEPTION 'AMBIGUITY: Multiple form configurations found for branch % (% records). Aborting.', v_branch_id, v_form_config_count;
    ELSIF v_form_config_count = 1 THEN
        RAISE NOTICE '[FORM CONFIG PRESERVED] Existing identification form configuration found for branch % (Preserving schema fields).', v_branch_id;
    ELSE
        RAISE NOTICE '[FORM CONFIG INSERT] Creating new default identification form configuration for branch %', v_branch_id;
        INSERT INTO public.branch_id_form_configs (
            id,
            branch_id,
            fields,
            created_at,
            updated_at
        )
        VALUES (
            gen_random_uuid(),
            v_branch_id,
            '[
                {"id": "photo", "label": "Identity Photo", "type": "photo", "isRequired": true, "isEnabled": true, "order": 0},
                {"id": "full_name", "label": "Full Name", "type": "text", "isRequired": true, "isEnabled": true, "order": 1},
                {"id": "email", "label": "Email Address", "type": "email", "isRequired": true, "isEnabled": true, "order": 2},
                {"id": "phone", "label": "Phone Number", "type": "phone", "isRequired": true, "isEnabled": true, "order": 3},
                {"id": "student_id", "label": "Student / Employee ID", "type": "text", "isRequired": true, "isEnabled": true, "order": 4}
            ]'::jsonb,
            timezone('utc', now()),
            timezone('utc', now())
        );
    END IF;

    RAISE NOTICE 'SUCCESS: Preflight complete. Techverve branch (%) configured for manager (%).', v_branch_id, v_manager_id;
END $$;

-- 5. Hardened Row Level Security Policies
DROP POLICY IF EXISTS "Applicants and members can view branch id form configs" ON public.branch_id_form_configs;
DROP POLICY IF EXISTS "Authenticated users can view branch id form configs" ON public.branch_id_form_configs;
DROP POLICY IF EXISTS "Authorized members and managers can view branch id form configs" ON public.branch_id_form_configs;

CREATE POLICY "Authorized members and managers can view branch id form configs"
ON public.branch_id_form_configs FOR SELECT
TO authenticated
USING (
    public.is_branch_member(branch_id)
    OR public.is_branch_manager(branch_id)
    OR public.has_branch_membership_request(branch_id)
);

DROP POLICY IF EXISTS "Branch managers can insert id form config for their branch" ON public.branch_id_form_configs;
CREATE POLICY "Branch managers can insert id form config for their branch"
ON public.branch_id_form_configs FOR INSERT
TO authenticated
WITH CHECK (public.is_branch_manager(branch_id));

DROP POLICY IF EXISTS "Branch managers can update id form config for their branch" ON public.branch_id_form_configs;
CREATE POLICY "Branch managers can update id form config for their branch"
ON public.branch_id_form_configs FOR UPDATE
TO authenticated
USING (public.is_branch_manager(branch_id))
WITH CHECK (public.is_branch_manager(branch_id));

DROP POLICY IF EXISTS "Authenticated users can register organization" ON public.organizations;
DROP POLICY IF EXISTS "Authenticated users can create organization" ON public.organizations;
DROP POLICY IF EXISTS "Authorized users can create organization" ON public.organizations;

CREATE POLICY "Authorized users can create organization"
ON public.organizations FOR INSERT
TO authenticated
WITH CHECK (
    created_by = auth.uid()
    AND length(trim(name)) >= 2
);

DROP POLICY IF EXISTS "Members and applicants can view their organization" ON public.organizations;
CREATE POLICY "Members and applicants can view their organization"
ON public.organizations FOR SELECT
TO authenticated
USING (
    created_by = auth.uid()
    OR EXISTS (
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

DROP POLICY IF EXISTS "Organization creators and web admins can update organization" ON public.organizations;
CREATE POLICY "Organization creators and web admins can update organization"
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

DROP POLICY IF EXISTS "Users can submit membership requests" ON public.branch_membership_requests;
CREATE POLICY "Users can submit membership requests"
ON public.branch_membership_requests FOR INSERT
TO authenticated
WITH CHECK (
    user_id = auth.uid()
    AND status = 'pending'
    AND reviewed_by IS NULL
    AND reviewed_at IS NULL
);

-- 6. Integrity Functions & Triggers
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

    NEW.updated_at := timezone('utc', now());
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_profile_update_integrity ON public.profiles;
CREATE TRIGGER trg_profile_update_integrity
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.check_profile_update_integrity();

CREATE OR REPLACE FUNCTION public.handle_membership_request_approval()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
DECLARE
    v_caller_role TEXT;
    v_caller_uid UUID;
    v_is_authorized BOOLEAN := FALSE;
    v_existing_assignment_id UUID;
BEGIN
    IF NEW.user_id IS DISTINCT FROM OLD.user_id THEN
        RAISE EXCEPTION 'Security violation: user_id cannot be modified on a membership request.';
    END IF;

    IF NEW.branch_id IS DISTINCT FROM OLD.branch_id THEN
        RAISE EXCEPTION 'Security violation: branch_id cannot be modified on a membership request.';
    END IF;

    v_caller_role := auth.role();
    v_caller_uid := auth.uid();

    IF v_caller_role = 'service_role' THEN
        v_is_authorized := TRUE;
    ELSIF v_caller_role IS NULL AND v_caller_uid IS NULL THEN
        v_is_authorized := TRUE;
    ELSIF v_caller_role = 'authenticated' AND v_caller_uid IS NOT NULL THEN
        IF public.is_branch_manager(OLD.branch_id) THEN
            v_is_authorized := TRUE;
        ELSIF EXISTS (
            SELECT 1 FROM public.user_branch_assignments
            WHERE user_id = v_caller_uid
              AND role = 'web_admin'
              AND is_active = TRUE
        ) THEN
            v_is_authorized := TRUE;
        END IF;
    END IF;

    IF NOT v_is_authorized THEN
        RAISE EXCEPTION 'Unauthorized: Only an authorized manager of the requested branch or an administrator can review membership requests.';
    END IF;

    IF NEW.status IS DISTINCT FROM OLD.status THEN
        IF v_caller_role = 'authenticated' AND v_caller_uid IS NOT NULL THEN
            IF NEW.reviewed_by IS DISTINCT FROM v_caller_uid THEN
                RAISE EXCEPTION 'Security violation: reviewed_by must match the authenticated reviewer.';
            END IF;
        END IF;

        IF NEW.status = 'approved' AND (OLD.status IS DISTINCT FROM 'approved') THEN
            UPDATE public.user_branch_assignments
            SET is_active = FALSE
            WHERE user_id = NEW.user_id
              AND role = 'member'
              AND is_active = TRUE;

            SELECT id INTO v_existing_assignment_id
            FROM public.user_branch_assignments
            WHERE user_id = NEW.user_id
              AND branch_id = NEW.branch_id
              AND role = 'member'
            ORDER BY created_at DESC
            LIMIT 1;

            IF v_existing_assignment_id IS NOT NULL THEN
                UPDATE public.user_branch_assignments
                SET is_active = TRUE,
                    effective_from = timezone('utc', now()),
                    effective_to = NULL
                WHERE id = v_existing_assignment_id;
            ELSE
                INSERT INTO public.user_branch_assignments (
                    id,
                    user_id,
                    branch_id,
                    role,
                    is_active,
                    effective_from,
                    created_at
                )
                VALUES (
                    gen_random_uuid(),
                    NEW.user_id,
                    NEW.branch_id,
                    'member',
                    TRUE,
                    timezone('utc', now()),
                    timezone('utc', now())
                );
            END IF;

        ELSIF NEW.status = 'rejected' AND OLD.status = 'approved' THEN
            UPDATE public.user_branch_assignments
            SET is_active = FALSE
            WHERE user_id = NEW.user_id
              AND branch_id = NEW.branch_id
              AND role = 'member'
              AND is_active = TRUE;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_membership_approval_assignment ON public.branch_membership_requests;
CREATE TRIGGER trg_membership_approval_assignment
    AFTER UPDATE ON public.branch_membership_requests
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_membership_request_approval();

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

    IF v_caller_role = 'service_role' THEN
        RETURN NEW;
    END IF;

    IF v_caller_role IS NULL AND v_caller_uid IS NULL THEN
        RETURN NEW;
    END IF;

    IF v_caller_role = 'authenticated' AND v_caller_uid IS NOT NULL THEN
        SELECT EXISTS (
            SELECT 1 FROM public.user_branch_assignments
            WHERE user_id = v_caller_uid
              AND role = 'web_admin'
              AND is_active = TRUE
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

-- 7. Explicit Grants for Authenticated Role
GRANT USAGE ON SCHEMA public TO authenticated, anon;

GRANT SELECT, INSERT, UPDATE ON TABLE public.branches TO authenticated;
GRANT SELECT, INSERT, UPDATE ON TABLE public.user_branch_assignments TO authenticated;
GRANT SELECT, INSERT, UPDATE ON TABLE public.branch_invite_codes TO authenticated;
GRANT SELECT, INSERT, UPDATE ON TABLE public.branch_membership_requests TO authenticated;
GRANT SELECT, INSERT, UPDATE ON TABLE public.branch_id_form_configs TO authenticated;
GRANT SELECT, INSERT, UPDATE ON TABLE public.organizations TO authenticated;
GRANT SELECT, INSERT, UPDATE ON TABLE public.profiles TO authenticated;

GRANT EXECUTE ON FUNCTION public.validate_branch_invite_code(TEXT) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION public.is_branch_manager(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_branch_member(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.has_branch_membership_request(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.shares_active_branch_with(UUID) TO authenticated;

COMMIT;
