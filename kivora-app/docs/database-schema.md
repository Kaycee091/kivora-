# Kivora Database Schema Specification

All tables reside in PostgreSQL, using UUID primary keys with default `gen_random_uuid()`, standard UTC timestamps (`timestamptz`), strict foreign keys, check constraints, and indexed lookup patterns.

---

## 1. Identity & Profiles
- `profiles`:
  - `id` (UUID, PK, references `auth.users.id` on delete cascade)
  - `full_name` (TEXT, NOT NULL)
  - `email` (TEXT, NOT NULL UNIQUE)
  - `phone_number` (TEXT)
  - `avatar_url` (TEXT)
  - `identifier_code` (TEXT, e.g. student/staff ID)
  - `account_status` (TEXT, CHECK: `active`, `suspended`, `pending_verification`, `archived`)
  - `created_at` (TIMESTAMPTZ, default `now()`)
  - `updated_at` (TIMESTAMPTZ, default `now()`)

- `identity_documents`:
  - `id` (UUID, PK)
  - `user_id` (UUID, references `profiles.id`)
  - `document_type` (TEXT, CHECK: `national_id`, `student_id`, `birth_certificate`, `passport`, `other`)
  - `file_path` (TEXT, NOT NULL)
  - `review_status` (TEXT, CHECK: `pending_review`, `reviewed`, `rejected`, `needs_resubmission`)
  - `reviewed_by` (UUID, references `profiles.id`)
  - `reviewed_at` (TIMESTAMPTZ)
  - `rejection_reason` (TEXT)
  - `created_at` (TIMESTAMPTZ)

## 2. Organization & Branches
- `organizations`:
  - `id` (UUID, PK)
  - `name` (TEXT, NOT NULL)
  - `organization_type` (TEXT, e.g. `school`, `corporate`, `retail`, `factory`)
  - `created_at` (TIMESTAMPTZ)

- `branches`:
  - `id` (UUID, PK)
  - `organization_id` (UUID, references `organizations.id`)
  - `name` (TEXT, NOT NULL)
  - `branch_code` (TEXT UNIQUE)
  - `description` (TEXT)
  - `address` (TEXT)
  - `latitude` (DOUBLE PRECISION)
  - `longitude` (DOUBLE PRECISION)
  - `geofence_radius_meters` (INTEGER DEFAULT 100)
  - `trusted_network_cidrs` (TEXT[] DEFAULT '{}')
  - `contact_email` (TEXT)
  - `contact_phone` (TEXT)
  - `created_at` (TIMESTAMPTZ)

- `branch_invite_codes`:
  - `id` (UUID, PK)
  - `branch_id` (UUID, references `branches.id`)
  - `code` (TEXT NOT NULL UNIQUE)
  - `created_by` (UUID, references `profiles.id`)
  - `allowed_roles` (TEXT[] NOT NULL)
  - `max_uses` (INTEGER DEFAULT 50)
  - `used_count` (INTEGER DEFAULT 0)
  - `expires_at` (TIMESTAMPTZ NOT NULL)
  - `is_revoked` (BOOLEAN DEFAULT FALSE)
  - `created_at` (TIMESTAMPTZ)

- `branch_membership_requests`:
  - `id` (UUID, PK)
  - `branch_id` (UUID, references `branches.id`)
  - `user_id` (UUID, references `profiles.id`)
  - `invite_code_id` (UUID, references `branch_invite_codes.id`)
  - `requested_role` (TEXT NOT NULL)
  - `status` (TEXT CHECK: `pending`, `approved`, `rejected`, `needs_information`)
  - `decision_reason` (TEXT)
  - `reviewed_by` (UUID, references `profiles.id`)
  - `reviewed_at` (TIMESTAMPTZ)
  - `created_at` (TIMESTAMPTZ)

- `user_branch_assignments`:
  - `id` (UUID, PK)
  - `user_id` (UUID, references `profiles.id`)
  - `branch_id` (UUID, references `branches.id`)
  - `role` (TEXT NOT NULL, e.g. `member`, `branch_manager`, `branch_admin`, `web_admin`)
  - `is_active` (BOOLEAN DEFAULT TRUE)
  - `effective_from` (TIMESTAMPTZ NOT NULL)
  - `effective_to` (TIMESTAMPTZ)
  - `created_at` (TIMESTAMPTZ)

## 3. Permissions & Granular Roles
- `role_definitions`:
  - `id` (UUID, PK)
  - `branch_id` (UUID, references `branches.id`, nullable for system roles)
  - `name` (TEXT NOT NULL)
  - `description` (TEXT)
  - `is_system_role` (BOOLEAN DEFAULT FALSE)

- `permissions`:
  - `id` (TEXT, PK, e.g. `attendance.check_in`, `attendance.view_logs`, `members.review_docs`)
  - `category` (TEXT NOT NULL)
  - `description` (TEXT)

- `role_permissions`:
  - `role_id` (UUID, references `role_definitions.id`)
  - `permission_id` (TEXT, references `permissions.id`)
  - PRIMARY KEY (`role_id`, `permission_id`)

## 4. Scheduling & Organizational Units
- `departments`:
  - `id` (UUID, PK)
  - `branch_id` (UUID, references `branches.id`)
  - `name` (TEXT NOT NULL)
  - `description` (TEXT)

- `classes`:
  - `id` (UUID, PK)
  - `branch_id` (UUID, references `branches.id`)
  - `department_id` (UUID, references `departments.id`)
  - `name` (TEXT NOT NULL)
  - `room` (TEXT)
  - `instructor_id` (UUID, references `profiles.id`)

- `schedule_sessions`:
  - `id` (UUID, PK)
  - `branch_id` (UUID, references `branches.id`)
  - `class_id` (UUID, references `classes.id`)
  - `title` (TEXT NOT NULL)
  - `start_time` (TIMESTAMPTZ NOT NULL)
  - `end_time` (TIMESTAMPTZ NOT NULL)
  - `check_in_window_minutes_before` (INTEGER DEFAULT 15)
  - `check_in_window_minutes_after` (INTEGER DEFAULT 30)
  - `status` (TEXT CHECK: `scheduled`, `in_progress`, `completed`, `cancelled`)

- `session_assignments`:
  - `id` (UUID, PK)
  - `session_id` (UUID, references `schedule_sessions.id`)
  - `user_id` (UUID, references `profiles.id`)
  - `assignment_type` (TEXT DEFAULT 'required')

## 5. Attendance & Verification
- `attendance_records`:
  - `id` (UUID, PK)
  - `branch_id` (UUID, references `branches.id`)
  - `session_id` (UUID, references `schedule_sessions.id`)
  - `user_id` (UUID, references `profiles.id`)
  - `check_in_time` (TIMESTAMPTZ)
  - `check_out_time` (TIMESTAMPTZ)
  - `duration_seconds` (INTEGER)
  - `status` (TEXT CHECK: `present`, `late`, `absent`, `half_day`, `needs_review`)
  - `overall_verification_status` (TEXT CHECK: `passed`, `failed`, `unavailable`, `needs_review`)
  - `created_at` (TIMESTAMPTZ)
  - `updated_at` (TIMESTAMPTZ)

- `attendance_events`:
  - `id` (UUID, PK)
  - `attendance_record_id` (UUID, references `attendance_records.id`)
  - `event_type` (TEXT CHECK: `check_in_attempt`, `check_in_confirmed`, `check_out_attempt`, `check_out_confirmed`, `correction_applied`)
  - `event_timestamp` (TIMESTAMPTZ NOT NULL)
  - `client_metadata` (JSONB)
  - `created_at` (TIMESTAMPTZ)

- `verification_logs`:
  - `id` (UUID, PK)
  - `attendance_record_id` (UUID, references `attendance_records.id`)
  - `user_id` (UUID, references `profiles.id`)
  - `verification_factor` (TEXT CHECK: `biometric`, `gps`, `network`)
  - `result` (TEXT CHECK: `passed`, `failed`, `unavailable`, `needs_review`)
  - `evidence_summary` (JSONB)
  - `failure_reason` (TEXT)
  - `created_at` (TIMESTAMPTZ)

## 6. Requests, Approvals & Audit
- `leave_requests`:
  - `id` (UUID, PK)
  - `branch_id` (UUID, references `branches.id`)
  - `user_id` (UUID, references `profiles.id`)
  - `leave_type` (TEXT CHECK: `annual`, `sick`, `casual`, `early_departure`, `other`)
  - `session_id` (UUID, references `schedule_sessions.id`)
  - `start_date` (TIMESTAMPTZ NOT NULL)
  - `end_date` (TIMESTAMPTZ NOT NULL)
  - `reason` (TEXT NOT NULL)
  - `status` (TEXT CHECK: `pending`, `approved`, `rejected`)
  - `reviewed_by` (UUID, references `profiles.id`)
  - `reviewed_at` (TIMESTAMPTZ)
  - `decision_reason` (TEXT)
  - `created_at` (TIMESTAMPTZ)

- `correction_requests`:
  - `id` (UUID, PK)
  - `attendance_record_id` (UUID, references `attendance_records.id`)
  - `user_id` (UUID, references `profiles.id`)
  - `proposed_check_in` (TIMESTAMPTZ)
  - `proposed_check_out` (TIMESTAMPTZ)
  - `reason` (TEXT NOT NULL)
  - `status` (TEXT CHECK: `pending`, `approved`, `rejected`)
  - `reviewed_by` (UUID, references `profiles.id`)
  - `reviewed_at` (TIMESTAMPTZ)
  - `decision_reason` (TEXT)
  - `created_at` (TIMESTAMPTZ)

- `transfer_requests`:
  - `id` (UUID, PK)
  - `user_id` (UUID, references `profiles.id`)
  - `source_branch_id` (UUID, references `branches.id`)
  - `target_branch_id` (UUID, references `branches.id`)
  - `reason` (TEXT NOT NULL)
  - `status` (TEXT CHECK: `pending`, `approved`, `rejected`, `completed`)
  - `reviewed_by` (UUID, references `profiles.id`)
  - `reviewed_at` (TIMESTAMPTZ)
  - `created_at` (TIMESTAMPTZ)

- `announcements`:
  - `id` (UUID, PK)
  - `branch_id` (UUID, references `branches.id`)
  - `author_id` (UUID, references `profiles.id`)
  - `target_role` (TEXT DEFAULT 'all')
  - `title` (TEXT NOT NULL)
  - `content` (TEXT NOT NULL)
  - `created_at` (TIMESTAMPTZ)

- `notifications`:
  - `id` (UUID, PK)
  - `user_id` (UUID, references `profiles.id`)
  - `category` (TEXT CHECK: `attendance`, `request`, `system`, `announcement`)
  - `title` (TEXT NOT NULL)
  - `body` (TEXT NOT NULL)
  - `is_read` (BOOLEAN DEFAULT FALSE)
  - `data_payload` (JSONB)
  - `created_at` (TIMESTAMPTZ)

- `audit_logs`:
  - `id` (UUID, PK)
  - `actor_id` (UUID, references `profiles.id`)
  - `branch_id` (UUID, references `branches.id`)
  - `action` (TEXT NOT NULL)
  - `target_entity` (TEXT NOT NULL)
  - `target_id` (UUID)
  - `changes` (JSONB)
  - `ip_address` (TEXT)
  - `created_at` (TIMESTAMPTZ DEFAULT now())
