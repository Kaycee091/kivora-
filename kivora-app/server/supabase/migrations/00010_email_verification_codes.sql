-- ============================================================================
-- 00010: App-managed email verification codes
-- ============================================================================
-- Verification emails are sent by the Kivora web server through Brevo SMTP,
-- not by Supabase Auth. Codes are stored here as HMAC hashes and are only
-- accessible with the service role key (RLS on, no policies, no grants).
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.email_verification_codes (
    email TEXT PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    code_hash TEXT NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    attempts INTEGER NOT NULL DEFAULT 0,
    last_sent_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.email_verification_codes ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.email_verification_codes FROM anon, authenticated;

-- Look up an auth user by email (supabase-js admin API has no direct lookup).
CREATE OR REPLACE FUNCTION public.get_auth_user_by_email(p_email TEXT)
RETURNS TABLE (id UUID, email_confirmed_at TIMESTAMPTZ)
LANGUAGE sql
SECURITY DEFINER
SET search_path = ''
AS $$
    SELECT u.id, u.email_confirmed_at
    FROM auth.users u
    WHERE lower(u.email) = lower(p_email)
    LIMIT 1;
$$;

REVOKE ALL ON FUNCTION public.get_auth_user_by_email(TEXT) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.get_auth_user_by_email(TEXT) FROM anon;
REVOKE ALL ON FUNCTION public.get_auth_user_by_email(TEXT) FROM authenticated;
GRANT EXECUTE ON FUNCTION public.get_auth_user_by_email(TEXT) TO service_role;
