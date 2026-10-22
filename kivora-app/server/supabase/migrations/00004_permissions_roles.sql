-- ============================================================================
-- 00004_permissions_roles.sql
-- Kivora Granular Roles, Permissions Catalog & Default Mappings
-- ============================================================================

-- 1. Permissions Table
CREATE TABLE IF NOT EXISTS public.permissions (
    id TEXT PRIMARY KEY,
    category TEXT NOT NULL,
    description TEXT NOT NULL
);

-- 2. Role Definitions Table
CREATE TABLE IF NOT EXISTS public.role_definitions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    branch_id UUID REFERENCES public.branches(id) ON DELETE CASCADE, -- NULL for system-wide default templates
    name TEXT NOT NULL,
    description TEXT,
    is_system_role BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- 3. Role Permissions Join Table
CREATE TABLE IF NOT EXISTS public.role_permissions (
    role_id UUID NOT NULL REFERENCES public.role_definitions(id) ON DELETE CASCADE,
    permission_id TEXT NOT NULL REFERENCES public.permissions(id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, permission_id)
);

-- Seed Default Permissions Catalog
INSERT INTO public.permissions (id, category, description) VALUES
    ('attendance.check_in', 'Attendance', 'Perform check-in verification'),
    ('attendance.check_out', 'Attendance', 'Perform check-out verification'),
    ('attendance.view_own', 'Attendance', 'View personal attendance history and totals'),
    ('attendance.view_branch_logs', 'Attendance', 'View branch attendance logs and records'),
    ('attendance.review_exceptions', 'Attendance', 'Review failed and flagged verification logs'),
    ('attendance.submit_correction', 'Attendance', 'Submit attendance correction request'),
    ('attendance.review_correction', 'Attendance', 'Approve or reject attendance corrections'),
    ('members.view_roster', 'Members', 'View member roster and profiles for branch'),
    ('members.review_identity_docs', 'Members', 'Inspect and review submitted identity documents'),
    ('members.approve_join_request', 'Members', 'Approve or reject membership join requests'),
    ('members.suspend_account', 'Members', 'Suspend or reactivate accounts'),
    ('branches.create_invite_code', 'Branch Management', 'Generate and revoke branch invite codes'),
    ('branches.manage_settings', 'Branch Management', 'Modify branch details, geofence, and network rules'),
    ('schedules.create_session', 'Schedules', 'Create and modify classes and session schedules'),
    ('schedules.assign_members', 'Schedules', 'Assign members and groups to sessions'),
    ('requests.submit_leave', 'Requests', 'Submit leave or early departure requests'),
    ('requests.review_leave', 'Requests', 'Approve or reject leave requests'),
    ('transfers.request_transfer', 'Transfers', 'Request transfer to another branch'),
    ('transfers.review_transfer', 'Transfers', 'Review and process branch transfer requests'),
    ('announcements.create', 'Communications', 'Publish announcements to branch members'),
    ('reports.view_branch', 'Reports', 'View aggregated branch attendance reports'),
    ('reports.export_data', 'Reports', 'Export branch records to CSV, XLSX, and PDF'),
    ('audit.view_logs', 'Audit', 'Inspect administrative audit trails'),
    ('roles.manage_permissions', 'Roles', 'Configure custom roles and delegated rights')
ON CONFLICT (id) DO NOTHING;
