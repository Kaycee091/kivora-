# Kivora Complete Screen Inventory & Mapping

The Kivora ecosystem comprises 90 primary functional screens across three client experiences plus 10 documented onboarding catalog states.

---

## 1. Member Mobile Application (36 Screens)

| Screen ID | Screen Name | Route Path | Access Level | Primary Action | Data Sources |
|---|---|---|---|---|---|
| M01 | Welcome / Splash | `/welcome` | Public | Navigate to Sign In or Sign Up | Auth Session State |
| M02 | Sign In | `/auth/sign-in` | Public | Authenticate with Email & Password | Supabase Auth |
| M03 | Create Account | `/auth/register` | Public | Register new profile credentials | Supabase Auth & Profiles |
| M04 | Email Verification | `/auth/verify-email` | Unverified | Submit 6-digit code or resend | Supabase Auth OTP |
| M05 | Join or Create Branch | `/branch/discover` | Authenticated | Choose to join via code or apply | Branch Discovery Service |
| M06 | Profile & Identity Setup | `/profile/setup` | Authenticated | Enter details & upload ID docs | Profiles & Document Storage |
| M07 | Branch Code & Preview | `/branch/preview` | Authenticated | Validate invitation code & preview | `branch_invite_codes` API |
| M08 | Join Request Status | `/branch/status` | Authenticated | View pending review state | `branch_membership_requests` |
| M09 | Member Home | `/member/home` | Approved Member | View next session, quick actions | Dashboard Aggregation API |
| M10 | Notifications | `/member/notifications` | Approved Member | Filter & mark notifications read | `notifications` |
| M11 | Search & Quick Actions | `/member/search` | Approved Member | Search allowed resources & tools | Client & Server Search |
| M12 | Check-In / Check-Out | `/member/attendance/check-in` | Approved Member | Execute verification & attendance | `attendance-check-in` Function |
| M13 | Biometric Verification | `/member/attendance/biometric` | Approved Member | Trigger local OS biometric prompt | `local_auth` Service |
| M14 | GPS Verification | `/member/attendance/gps` | Approved Member | Check coordinate geofence | `geolocator` & Server Validation |
| M15 | Network Verification | `/member/attendance/network` | Approved Member | Check authorized network / IP | Server Network Verifier |
| M16 | Verification Result | `/member/attendance/result` | Approved Member | View result (Passed/Failed/Review) | Verification Log Result |
| M17 | Session Details | `/member/schedules/:id` | Approved Member | View session schedule & location | `schedule_sessions` |
| M18 | Attendance History | `/member/attendance/history` | Approved Member | Filter records by date/range | `attendance_records` |
| M19 | Attendance Record Details | `/member/attendance/records/:id` | Approved Member | View timestamps, verification info | Record Details API |
| M20 | Schedule / Calendar | `/member/schedule` | Approved Member | Browse calendar & session cards | `schedule_sessions` Assigned |
| M21 | Attendance Totals | `/member/attendance/totals` | Approved Member | View attendance rate & breakdown | Calculated Metrics API |
| M22 | Digital ID | `/member/digital-id` | Approved Member | Display member photo ID & QR code | Profiles & Branch Membership |
| M23 | Class / Team Information | `/member/classes/:id` | Approved Member | View overview, roster, schedule | `classes` / `session_assignments` |
| M24 | Department & Assignments | `/member/department` | Approved Member | View department info & role | `departments` & User Profile |
| M25 | Branch Information | `/member/branch` | Approved Member | View address, contact, operating info | `branches` |
| M26 | Leave / Early Leave | `/member/requests/leave/new` | Approved Member | Submit leave or early departure | `submit-leave-request` |
| M27 | Missed Check-Out / Correction | `/member/requests/correction/new` | Approved Member | Submit attendance correction | `submit-attendance-correction` |
| M28 | Requests & Decisions | `/member/requests` | Approved Member | View history of leave/corrections | `leave_requests`, `correction_requests` |
| M29 | Profile | `/member/profile` | Approved Member | View profile details & categories | `profiles` |
| M30 | Edit Profile | `/member/profile/edit` | Approved Member | Update mutable personal fields | Profile Mutation API |
| M31 | Request Branch Transfer | `/member/transfer/new` | Approved Member | Select target branch & reason | `submit-branch-transfer` |
| M32 | Transfer Status / History | `/member/transfer/history` | Approved Member | View transfer request outcomes | `transfer_requests` |
| M33 | App Settings | `/member/settings` | Authenticated | Toggle theme, language, biometrics | Local Preferences Storage |
| M34 | Security & Biometrics | `/member/settings/security` | Authenticated | Manage biometric lock & security | Local & Server Auth Config |
| M35 | Device & Permission Status | `/member/settings/permissions` | Authenticated | View & guide device permissions | OS Permission Handler |
| M36 | Help, Privacy & Support | `/member/settings/help` | Authenticated | FAQs, contact support, privacy notice | Static Help / Support API |

---

## 2. Branch Manager Mobile Application (27 Screens)

| Screen ID | Screen Name | Route Path | Access Level | Primary Action | Data Sources |
|---|---|---|---|---|---|
| BM01 | Sign In | `/manager/sign-in` | Public | Manager login with branch scope | Supabase Auth & Role Matrix |
| BM02 | Email Verification | `/manager/verify-email` | Unverified | Validate email token | Supabase Auth OTP |
| BM03 | Create or Join Branch | `/manager/branch-gateway` | Authenticated | Branch creation or invitation flow | Branch Admin Operations |
| BM04 | Create Branch: Details | `/manager/branch/new` | Authorized Creator | Configure name, type, location | `branches` Table |
| BM05 | Create Branch: Initial Admin | `/manager/branch/new/admin` | Authorized Creator | Setup first branch admin profile | `user_branch_assignments` |
| BM06 | Branch Created Confirmation | `/manager/branch/new/success` | Branch Manager | View generated details & continue | Created Branch Record |
| BM07 | Branch Manager Dashboard | `/manager/dashboard` | Branch Manager | View branch KPIs & action alerts | Manager Dashboard API |
| BM08 | Members List | `/manager/members` | Branch Manager | Search, filter, inspect members | Branch Members Query |
| BM09 | Member Profile Details | `/manager/members/:id` | Branch Manager | View member profile & attendance | Member Profile Record |
| BM10 | Document Review | `/manager/members/:id/documents` | Branch Reviewer | Approve/reject submitted documents | `review-identity-document` |
| BM11 | Membership Approval | `/manager/requests/membership` | Branch Manager | Approve/reject join requests | `review-membership-request` |
| BM12 | Generate Invitation Code | `/manager/invites/generate` | Branch Manager | Create time/role limited code | `branch_invite_codes` API |
| BM13 | Attendance Logs | `/manager/attendance/logs` | Branch Manager | View live & historical logs | Branch `attendance_records` |
| BM14 | Early Leave Requests | `/manager/requests/early-leave` | Branch Manager | Review early departure requests | `leave_requests` (Early Leave) |
| BM15 | Send Announcement | `/manager/announcements/new` | Branch Manager | Broadcast announcement to branch | `send-announcement` |
| BM16 | Schedule Management | `/manager/schedules` | Branch Manager | Create/modify sessions & shifts | `manage-schedule` |
| BM17 | Reports | `/manager/reports` | Branch Manager | View branch attendance summaries | `generate-report` |
| BM18 | Branch Settings | `/manager/settings/branch` | Branch Manager | Edit operating hours, geofence | Branch Config API |
| BM19 | Role Permissions | `/manager/settings/roles` | Branch Manager | Toggle delegated permissions | `role_permissions` Table |
| BM20 | Verification Logs | `/manager/logs/verification` | Branch Manager | Inspect biometric/GPS exceptions | `verification_logs` |
| BM21 | Audit History | `/manager/logs/audit` | Branch Manager | Review administrative audit trail | `audit_logs` |
| BM22 | Branch Messages | `/manager/messages` | Branch Manager | Broadcast messages by role | `announcements` & Messages |
| BM23 | Branch Members Overview | `/manager/members/overview` | Branch Manager | View membership statistics | Branch Aggregations |
| BM24 | Attendance Overview | `/manager/attendance/overview` | Branch Manager | Gauge attendance rates by role | Attendance Metrics API |
| BM25 | Leave Management | `/manager/requests/leave` | Branch Manager | Approve/reject leave applications | Leave Review API |
| BM26 | Create / Edit Role | `/manager/roles/edit` | Branch Manager | Configure custom roles & rights | Role Definition API |
| BM27 | Branch Transfer | `/manager/requests/transfers` | Branch Manager | Review inbound/outbound transfers | `review-branch-transfer` |

---

## 3. Web Admin Dashboard (27 Screens)

| Screen ID | Screen Name | Route Path | Access Level | Primary Action | Data Sources |
|---|---|---|---|---|---|
| WA01 | Admin Dashboard | `/dashboard` | Web Admin | Executive overview & system trends | Admin Analytics Engine |
| WA02 | Live Attendance | `/attendance/live` | Web Admin | Real-time attendance monitor | Supabase Realtime / Polling |
| WA03 | Attendance Record Detail | `/attendance/records/:id` | Web Admin | Inspect session events & telemetry | Single Record Detail API |
| WA04 | Exceptions & Review Queue | `/attendance/exceptions` | Web Admin | Resolve failed/flagged verifications | Flagged Verification Logs |
| WA05 | Member Directory | `/members` | Web Admin | TanStack Table directory of members | Paginated Members Query |
| WA06 | Join Requests & ID Review | `/members/requests` | Web Admin | Dual review for joins and ID docs | Pending Requests API |
| WA07 | Member Profile & Permissions | `/members/:id/permissions` | Web Admin | Manage granular role grants | Permissions Matrix API |
| WA08 | Class/Team Enrollments | `/organization/enrollments` | Web Admin | Mass enroll and unassign members | `session_assignments` |
| WA09 | Suspend / Reactivate Account | `/members/:id/status` | Web Admin | Execute auditable account lock | `manage-account-status` |
| WA10 | Branch Overview | `/branches` | Web Admin | Global branch directory & health | `branches` Table |
| WA11 | Branch Geofence Setup | `/branches/:id/geofence` | Web Admin | Interactive map & radius config | Geofence Coordinates Store |
| WA12 | Network Verification Setup | `/branches/:id/network` | Web Admin | Configure trusted IP / gateway | Branch Network Policies |
| WA13 | Branch Managers & Scopes | `/branches/:id/managers` | Web Admin | Assign managers & scopes | `user_branch_assignments` |
| WA14 | Attendance Rules | `/policies/attendance` | Web Admin | Configure check-in grace periods | `attendance_policies` |
| WA15 | Schedule & Session Windows | `/schedules/windows` | Web Admin | Configure class & shift windows | `schedule_sessions` |
| WA16 | Breaks & Duration Rules | `/policies/breaks` | Web Admin | Define auto-deductions & limits | Policy Duration Rules |
| WA17 | Manual Corrections | `/attendance/corrections` | Web Admin | Audit & approve manual entries | Correction Review Workflow |
| WA18 | Class, Team & Groups | `/organization/groups` | Web Admin | Create and manage organizational units | `classes`, `teams` |
| WA19 | Department Management | `/organization/departments`| Web Admin | Manage structural departments | `departments` |
| WA20 | Assignments & Roles | `/organization/responsibilities`| Web Admin | Assign operational duties | Duty Assignments Store |
| WA21 | Reports & Analytics | `/reports` | Web Admin | Recharts graphs & custom filters | Reporting Aggregation Store |
| WA22 | Export Center | `/exports` | Web Admin | Generate secure CSV/PDF/XLSX | `create-export` Function |
| WA23 | Leave & Correction Reviews | `/approvals/requests` | Web Admin | Queue for all branch requests | Requests Queue API |
| WA24 | Branch Transfer Reviews | `/approvals/transfers` | Web Admin | System-wide transfer oversight | `transfer_requests` |
| WA25 | Audit History | `/audit` | Web Admin | Immutable system audit explorer | `audit_logs` |
| WA26 | Security & Verification Logs | `/security/logs` | Web Admin | Investigate security incidents | `verification_logs` |
| WA27 | Branch Settings & Announcements| `/settings/operations` | Web Admin | Centralized operational settings | Multi-tenant Config Store |

---

## 4. Branch Onboarding Catalog (10 States / Entries)

| Catalog ID | Step Name | Implemented By | Target Screen/Route |
|---|---|---|---|
| BO01 | Branch Manager Sign In | Shared Auth | BM01 (`/manager/sign-in`) |
| BO02 | Email Verification | Shared Auth | BM02 (`/manager/verify-email`) |
| BO03 | Create or Join Branch | Branch Gateway | BM03 (`/manager/branch-gateway`) |
| BO04 | Branch Details | Branch Creation Wizard | BM04 (`/manager/branch/new`) |
| BO05 | Add Initial Admin | Branch Creation Wizard | BM05 (`/manager/branch/new/admin`) |
| BO06 | Success Confirmation | Branch Creation Wizard | BM06 (`/manager/branch/new/success`) |
| BO07 | Join Branch: Code Input | Member & Manager Join | M07 / BM03 (`/branch/preview`) |
| BO08 | Branch Information Preview | Branch Verification Flow | M07 (`/branch/preview`) |
| BO09 | Request to Join | Membership Submission | M06 / M07 (`/branch/status`) |
| BO10 | Awaiting Approval | Status Display State | M08 (`/branch/status`) |
