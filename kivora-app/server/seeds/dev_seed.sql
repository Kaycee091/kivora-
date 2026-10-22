-- ============================================================================
-- dev_seed.sql
-- DEVELOPMENT SEED DATA ONLY (DO NOT RUN IN PRODUCTION)
-- ============================================================================

-- 1. Organizations
INSERT INTO public.organizations (id, name, organization_type) VALUES
    ('11111111-1111-1111-1111-111111111111', 'Kivora Institute of Technology', 'school'),
    ('22222222-2222-2222-2222-222222222222', 'Apex Corporate Logistics', 'corporate')
ON CONFLICT (id) DO NOTHING;

-- 2. Branches
INSERT INTO public.branches (id, organization_id, name, branch_code, description, address, latitude, longitude, geofence_radius_meters, contact_email) VALUES
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'West Campus', 'KIV-WEST-01', 'Main Academic Science and Engineering Hub', '12 Education Road, Lagos, Nigeria', 6.5244, 3.3792, 150, 'westcampus@kivora.edu.ng'),
    ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '11111111-1111-1111-1111-111111111111', 'East Campus', 'KIV-EAST-02', 'Humanities, Business, and Arts Campus', '45 Innovation Crescent, Enugu, Nigeria', 6.4584, 7.5464, 120, 'eastcampus@kivora.edu.ng')
ON CONFLICT (id) DO NOTHING;

-- 3. Departments & Classes
INSERT INTO public.departments (id, branch_id, name, description) VALUES
    ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Computer Science', 'Department of Computing and Software Systems')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.classes (id, branch_id, department_id, name, room) VALUES
    ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'Computer Science 201', 'Block B - Room 203')
ON CONFLICT (id) DO NOTHING;

-- 4. Active Branch Invite Codes
INSERT INTO public.branch_invite_codes (id, branch_id, code, allowed_roles, max_uses, used_count, expires_at) VALUES
    ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'KIV-8F3D-7A2B', '{"student", "teacher", "staff"}', 50, 4, timezone('utc', now() + interval '30 days'))
ON CONFLICT (id) DO NOTHING;
