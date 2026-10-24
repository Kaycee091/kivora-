-- ============================================================================
-- 00001_initial_schema.sql
-- Kivora Identity, Organizations, Branches & Membership Schema
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. Profiles Table (linked to Supabase auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone_number TEXT,
    avatar_url TEXT,
    identifier_code TEXT, -- e.g. Student ID or Employee Code
    account_status TEXT NOT NULL DEFAULT 'active' CHECK (account_status IN ('active', 'suspended', 'pending_verification', 'archived')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- 2. Organizations Table
CREATE TABLE IF NOT EXISTS public.organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    organization_type TEXT NOT NULL DEFAULT 'school',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- 3. Branches Table
CREATE TABLE IF NOT EXISTS public.branches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    branch_code TEXT UNIQUE,
    description TEXT,
    address TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    geofence_radius_meters INTEGER NOT NULL DEFAULT 100,
    trusted_network_cidrs TEXT[] NOT NULL DEFAULT '{}',
    contact_email TEXT,
    contact_phone TEXT,
    created_by UUID REFERENCES public.profiles(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);


-- 4. User Branch Assignments (Tracks active membership & scoped roles)
CREATE TABLE IF NOT EXISTS public.user_branch_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    branch_id UUID NOT NULL REFERENCES public.branches(id) ON DELETE CASCADE,
    role TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('member', 'branch_manager', 'branch_admin', 'web_admin')),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    effective_from TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    effective_to TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- Unique index ensuring ordinary members have exactly one active branch at a time
CREATE UNIQUE INDEX IF NOT EXISTS idx_user_single_active_branch
ON public.user_branch_assignments (user_id)
WHERE is_active = TRUE AND role = 'member';

-- 5. Branch Invite Codes Table
CREATE TABLE IF NOT EXISTS public.branch_invite_codes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    branch_id UUID NOT NULL REFERENCES public.branches(id) ON DELETE CASCADE,
    code TEXT NOT NULL UNIQUE,
    created_by UUID REFERENCES public.profiles(id),
    allowed_roles TEXT[] NOT NULL DEFAULT '{"member"}',
    max_uses INTEGER NOT NULL DEFAULT 50,
    used_count INTEGER NOT NULL DEFAULT 0,
    expires_at TIMESTAMPTZ NOT NULL,
    is_revoked BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- 6. Branch Membership Requests Table
CREATE TABLE IF NOT EXISTS public.branch_membership_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    branch_id UUID NOT NULL REFERENCES public.branches(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    invite_code_id UUID REFERENCES public.branch_invite_codes(id),
    requested_role TEXT NOT NULL DEFAULT 'student',
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'needs_information')),
    decision_reason TEXT,
    reviewed_by UUID REFERENCES public.profiles(id),
    reviewed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- 7. Identity Documents Table (stored in private Supabase Storage)
CREATE TABLE IF NOT EXISTS public.identity_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    document_type TEXT NOT NULL CHECK (document_type IN ('national_id', 'student_id', 'birth_certificate', 'passport', 'other')),
    file_path TEXT NOT NULL,
    review_status TEXT NOT NULL DEFAULT 'pending_review' CHECK (review_status IN ('pending_review', 'reviewed', 'rejected', 'needs_resubmission')),
    reviewed_by UUID REFERENCES public.profiles(id),
    reviewed_at TIMESTAMPTZ,
    rejection_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- Indexing for quick lookups
CREATE INDEX IF NOT EXISTS idx_branches_org_id ON public.branches(organization_id);
CREATE INDEX IF NOT EXISTS idx_assignments_user ON public.user_branch_assignments(user_id);
CREATE INDEX IF NOT EXISTS idx_assignments_branch ON public.user_branch_assignments(branch_id);
CREATE INDEX IF NOT EXISTS idx_membership_req_branch ON public.branch_membership_requests(branch_id);
CREATE INDEX IF NOT EXISTS idx_membership_req_status ON public.branch_membership_requests(status);

-- ============================================================================
-- 8. Automatic Profile Creation Trigger on auth.users
-- ============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
DECLARE
    user_full_name TEXT;
    user_email TEXT;
BEGIN
    -- Safely extract full name from user metadata or derive from email prefix
    user_full_name := COALESCE(
        NULLIF(TRIM(NEW.raw_user_meta_data->>'full_name'), ''),
        NULLIF(TRIM(NEW.raw_user_meta_data->>'name'), ''),
        SPLIT_PART(COALESCE(NEW.email, 'User'), '@', 1)
    );

    user_email := COALESCE(
        NULLIF(TRIM(NEW.email), ''),
        NEW.id::text || '@auth.kivora.local'
    );

    INSERT INTO public.profiles (
        id,
        full_name,
        email,
        account_status,
        created_at,
        updated_at
    )
    VALUES (
        NEW.id,
        user_full_name,
        user_email,
        'active',
        timezone('utc', now()),
        timezone('utc', now())
    )
    ON CONFLICT (id) DO UPDATE
    SET
        email = EXCLUDED.email,
        full_name = CASE 
            WHEN public.profiles.full_name IS NULL OR TRIM(public.profiles.full_name) = '' 
            THEN EXCLUDED.full_name 
            ELSE public.profiles.full_name 
        END,
        updated_at = timezone('utc', now());

    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'handle_new_user failed for auth.users id %: %', NEW.id, SQLERRM;
        RETURN NEW;
END;
$$;


-- Restrict execution so client cannot invoke trigger function directly
REVOKE ALL ON FUNCTION public.handle_new_user() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.handle_new_user() FROM anon;
REVOKE ALL ON FUNCTION public.handle_new_user() FROM authenticated;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

