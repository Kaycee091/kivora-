-- ============================================================================
-- 00009_techverve_verification_query.sql
-- Pure Read-Only Preflight & Post-Migration Verification SQL
-- Zero writes. Zero RPC execution. Pure inspection of catalog & application tables.
-- ============================================================================

-- 1a. Independent Check for Duplicate Branch Names
SELECT 
    name, 
    COUNT(*) AS duplicate_count
FROM public.branches
GROUP BY name
HAVING COUNT(*) > 1;

-- 1b. Independent Check for Duplicate Branch Codes
SELECT 
    branch_code, 
    COUNT(*) AS duplicate_count
FROM public.branches
WHERE branch_code IS NOT NULL
GROUP BY branch_code
HAVING COUNT(*) > 1;

-- 1c. Independent Check for Duplicate Invite Codes
SELECT 
    code, 
    COUNT(*) AS duplicate_count
FROM public.branch_invite_codes
GROUP BY code
HAVING COUNT(*) > 1;

-- 2. Verify RLS is Enabled on All 7 Target Tables
SELECT 
    schemaname, 
    tablename, 
    rowsecurity AS rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN (
      'branches', 
      'branch_invite_codes', 
      'branch_membership_requests', 
      'user_branch_assignments', 
      'branch_id_form_configs', 
      'organizations', 
      'profiles'
  )
ORDER BY tablename;

-- 3. Inspect All RLS Policies Across Target Tables (Auditing Permissive & Restrictive Policies)
SELECT 
    schemaname, 
    tablename, 
    policyname, 
    permissive, 
    roles, 
    cmd, 
    qual AS using_expression, 
    with_check AS with_check_expression
FROM pg_catalog.pg_policies
WHERE schemaname = 'public' 
  AND tablename IN (
      'branches', 
      'branch_invite_codes', 
      'branch_membership_requests', 
      'user_branch_assignments', 
      'branch_id_form_configs', 
      'organizations', 
      'profiles'
  )
ORDER BY tablename, cmd, policyname;

-- 4. Inspect Effective Table Privileges for Authenticated, Anon, and Public Roles
SELECT 
    table_name, 
    grantee, 
    privilege_type
FROM information_schema.table_privileges
WHERE table_schema = 'public'
  AND table_name IN (
      'branches', 
      'branch_invite_codes', 
      'branch_membership_requests', 
      'user_branch_assignments', 
      'branch_id_form_configs', 
      'organizations', 
      'profiles'
  )
  AND grantee IN ('authenticated', 'anon', 'public')
ORDER BY table_name, grantee, privilege_type;

-- 5. Inspect Column-Level Privileges on Target Tables
SELECT 
    table_name, 
    column_name, 
    grantee, 
    privilege_type
FROM information_schema.column_privileges
WHERE table_schema = 'public'
  AND table_name IN (
      'branches', 
      'branch_invite_codes', 
      'branch_membership_requests', 
      'user_branch_assignments', 
      'branch_id_form_configs', 
      'organizations', 
      'profiles'
  )
  AND grantee IN ('authenticated', 'anon', 'public')
ORDER BY table_name, column_name, grantee;

-- 6. Inspect Triggers and Trigger Function Implementations
SELECT 
    t.event_object_table, 
    t.trigger_name, 
    t.event_manipulation, 
    t.action_timing, 
    t.action_statement,
    p.prosrc AS function_body
FROM information_schema.triggers t
JOIN pg_proc p ON p.proname = regexp_replace(t.action_statement, '^EXECUTE (FUNCTION|PROCEDURE) (public\.)?([a-zA-Z0-9_]+)\(.*$', '\3')
WHERE t.event_object_schema = 'public'
  AND t.event_object_table IN (
      'branch_membership_requests', 
      'user_branch_assignments', 
      'profiles'
  )
ORDER BY t.event_object_table, t.trigger_name;

-- 7. Inspect Techverve Branch & Ownership Linkage
SELECT 
    b.id AS branch_id,
    b.name AS branch_name,
    b.branch_code,
    b.organization_id,
    o.name AS organization_name,
    b.created_by AS manager_user_id,
    p.email AS manager_email,
    b.contact_email,
    b.contact_phone,
    b.created_at
FROM public.branches b
LEFT JOIN public.organizations o ON o.id = b.organization_id
LEFT JOIN public.profiles p ON p.id = b.created_by
WHERE b.name = 'Techverve' OR b.branch_code = 'KAYCEE2006';

-- 8. Inspect Invitation Code KAYCEE2006 & Counters
SELECT 
    bic.id AS invite_code_id,
    bic.code,
    bic.branch_id,
    b.name AS branch_name,
    bic.created_by AS creator_user_id,
    p.email AS creator_email,
    bic.allowed_roles,
    bic.used_count,
    bic.max_uses,
    bic.is_revoked,
    bic.expires_at,
    CASE 
        WHEN bic.is_revoked = FALSE AND bic.expires_at > timezone('utc', now()) AND bic.used_count < bic.max_uses THEN 'ACTIVE_AND_VALID'
        ELSE 'INVALID_OR_EXPIRED'
    END AS validity_state
FROM public.branch_invite_codes bic
LEFT JOIN public.branches b ON b.id = bic.branch_id
LEFT JOIN public.profiles p ON p.id = bic.created_by
WHERE bic.code = 'KAYCEE2006';

-- 9. Inspect User Branch Assignments for Manager & Member
SELECT 
    uba.id AS assignment_id,
    uba.user_id,
    p.email AS user_email,
    p.full_name,
    uba.branch_id,
    b.name AS branch_name,
    uba.role,
    uba.is_active,
    uba.effective_from,
    uba.created_at
FROM public.user_branch_assignments uba
JOIN public.profiles p ON p.id = uba.user_id
JOIN public.branches b ON b.id = uba.branch_id
WHERE p.email IN (
    'asogwakenechukwu284@gmail.com',
    'kenechukwuasogwa284@gmail.com'
)
ORDER BY p.email, uba.created_at DESC;

-- 10. Inspect Branch ID Form Configuration for Techverve
SELECT 
    fc.id AS config_id,
    fc.branch_id,
    b.name AS branch_name,
    jsonb_array_length(fc.fields) AS field_count,
    fc.fields,
    fc.updated_at
FROM public.branch_id_form_configs fc
JOIN public.branches b ON b.id = fc.branch_id
WHERE b.name = 'Techverve';

-- 11. Inspect Auth Users Confirmation Status (Supported Supabase Auth interface)
SELECT 
    id, 
    email, 
    email_confirmed_at, 
    last_sign_in_at, 
    created_at
FROM auth.users
WHERE email IN (
    'asogwakenechukwu284@gmail.com',
    'kenechukwuasogwa284@gmail.com'
);
