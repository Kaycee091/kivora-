# Kivora Requirements Traceability Matrix

This matrix maps core functional requirements from `Kivora_Client_Friendly_PRD_v4(1).pdf` to their implementing screens, Edge Functions, database entities, and test suites.

| PRD Section | Functional Requirement | Implementing Screens | Backend Function / Table | Automated Tests |
|---|---|---|---|---|
| 3.1 | Account registration & email verification | M01-M04, BM01-BM02 | `profiles`, Supabase Auth | `tests/unit/auth_test.dart`, `web/admin/tests/unit/auth.test.ts` |
| 3.2 | Branch creation & initial manager admin | BM03-BM06, BO03-BO06 | `branches`, `user_branch_assignments` | `server/tests/branch_test.sql` |
| 3.3 | Branch code validation & join request | M07-M08, BO07-BO10 | `submit-membership-request`, `branch_invite_codes` | `server/tests/membership_test.ts` |
| 3.4 | Profile & identity document review | M06, BM04, BM10, WA06 | `review-identity-document`, `identity_documents` | `server/tests/document_review_test.ts` |
| 3.5 | Roles and granular permissions | BM13, BM20, WA07 | `role_permissions`, `permissions` | `server/tests/permissions_test.sql` |
| 3.6 | Member home dashboard & stats | M09, BM07, WA01 | `attendance_records` aggregations | `web/admin/tests/components/dashboard.test.tsx` |
| 3.7 | Attendance check-in / check-out | M12-M16, WA02-WA04 | `attendance-check-in`, `attendance-check-out` | `server/tests/attendance_test.ts` |
| 3.8 | Attendance history & calendar | M17-M21, BM07, BM24 | `attendance_records`, `attendance_events` | `test/widget/attendance_card_test.dart` |
| 3.9 | Schedules, classes & sessions | M20, BM10, WA15 | `manage-schedule`, `schedule_sessions` | `server/tests/schedule_test.ts` |
| 3.10 | Leave, early leave & corrections | M26-M28, BM08, BM19, WA23 | `submit-leave-request`, `submit-attendance-correction` | `server/tests/requests_test.ts` |
| 3.11 | Announcements & notifications | M10, BM09, BM16, WA27 | `send-announcement`, `notifications` | `server/tests/announcement_test.ts` |
| 3.12 | Digital Member ID & QR Code | M22 | `profiles`, `user_branch_assignments` | `test/widget/digital_id_test.dart` |
| 3.13 | Reports & filtered data exports | BM11, WA21-WA22 | `create-export`, `generate-report` | `web/admin/tests/unit/export.test.ts` |
| 3.14 | Audit history & verification review | BM14-BM15, WA25-WA26 | `audit_logs`, `verification_logs` | `server/tests/audit_test.sql` |
| 3.15 | Privacy, device settings & support | M31-M36, BM21-BM27 | `profiles`, Local preferences | `test/widget/settings_test.dart` |
