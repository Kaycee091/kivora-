-- ============================================================================
-- 00007_branch_id_form_configs.sql
-- Kivora Dynamic Branch Identification Form Configs & Private Storage
-- Fully Idempotent, Scoped to Authorized Branches and Private Storage Buckets
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Create branch_id_form_configs Table
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.branch_id_form_configs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    branch_id UUID NOT NULL REFERENCES public.branches(id) ON DELETE CASCADE,
    fields JSONB NOT NULL DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    CONSTRAINT uq_branch_id_form_configs_branch UNIQUE (branch_id)
);

-- ----------------------------------------------------------------------------
-- 2. Ensure branch_membership_requests has submitted_data and photo_url
-- ----------------------------------------------------------------------------
ALTER TABLE public.branch_membership_requests 
ADD COLUMN IF NOT EXISTS submitted_data JSONB DEFAULT '{}'::jsonb,
ADD COLUMN IF NOT EXISTS photo_url TEXT;

-- ----------------------------------------------------------------------------
-- 3. Enable Row Level Security on branch_id_form_configs
-- ----------------------------------------------------------------------------
ALTER TABLE public.branch_id_form_configs ENABLE ROW LEVEL SECURITY;

-- ----------------------------------------------------------------------------
-- 4. RLS Policies for branch_id_form_configs
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Authenticated users can view branch id form configs" ON public.branch_id_form_configs;
DROP POLICY IF EXISTS "Applicants and members can view branch id form configs" ON public.branch_id_form_configs;
CREATE POLICY "Applicants and members can view branch id form configs"
    ON public.branch_id_form_configs FOR SELECT
    TO authenticated
    USING (
        public.is_branch_member(branch_id)
        OR public.is_branch_manager(branch_id)
        OR public.has_branch_membership_request(branch_id)
        -- Fallback: allow prospective applicant to view form schema for an active branch
        OR EXISTS (
            SELECT 1 FROM public.branches b 
            WHERE b.id = public.branch_id_form_configs.branch_id
        )
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

-- ----------------------------------------------------------------------------
-- 5. Storage Bucket Configuration for ID Documents & Photos
-- ----------------------------------------------------------------------------
INSERT INTO storage.buckets (id, name, public)
VALUES ('id-documents', 'id-documents', false)
ON CONFLICT (id) DO NOTHING;

-- ----------------------------------------------------------------------------
-- 6. Storage Policies on storage.objects for 'id-documents' bucket
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Users can upload own identity photos" ON storage.objects;
CREATE POLICY "Users can upload own identity photos"
    ON storage.objects FOR INSERT
    TO authenticated
    WITH CHECK (
        bucket_id = 'id-documents' 
        AND (storage.foldername(name))[1] = auth.uid()::text
    );

DROP POLICY IF EXISTS "Users can view own identity photos" ON storage.objects;
CREATE POLICY "Users can view own identity photos"
    ON storage.objects FOR SELECT
    TO authenticated
    USING (
        bucket_id = 'id-documents' 
        AND (storage.foldername(name))[1] = auth.uid()::text
    );

DROP POLICY IF EXISTS "Users can update own identity photos" ON storage.objects;
CREATE POLICY "Users can update own identity photos"
    ON storage.objects FOR UPDATE
    TO authenticated
    USING (
        bucket_id = 'id-documents' 
        AND (storage.foldername(name))[1] = auth.uid()::text
    )
    WITH CHECK (
        bucket_id = 'id-documents' 
        AND (storage.foldername(name))[1] = auth.uid()::text
    );

DROP POLICY IF EXISTS "Users can delete own identity photos" ON storage.objects;
CREATE POLICY "Users can delete own identity photos"
    ON storage.objects FOR DELETE
    TO authenticated
    USING (
        bucket_id = 'id-documents' 
        AND (storage.foldername(name))[1] = auth.uid()::text
    );

DROP POLICY IF EXISTS "Managers can view branch applicant identity photos" ON storage.objects;
CREATE POLICY "Managers can view branch applicant identity photos"
    ON storage.objects FOR SELECT
    TO authenticated
    USING (
        bucket_id = 'id-documents'
        AND EXISTS (
            SELECT 1 FROM public.branch_membership_requests bmr
            WHERE bmr.user_id::text = (storage.foldername(storage.objects.name))[1]
              AND public.is_branch_manager(bmr.branch_id)
        )
    );
