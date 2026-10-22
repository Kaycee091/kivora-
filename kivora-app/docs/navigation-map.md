# Kivora Navigation Map & State Routing

## 1. Member Mobile Navigation

### Root Bottom Navigation Bar
- **Tab 1: Home** (`/member/home` - Screen M09)
  - Quick action: Check-In (`/member/attendance/check-in` - M12) -> Verification Flow (M13-M16)
  - Quick action: My Schedule (`/member/schedule` - M20)
  - Quick action: Attendance History (`/member/attendance/history` - M18)
  - Quick action: My Profile (`/member/profile` - M29)
  - Header actions: Notifications (`/member/notifications` - M10), Search (`/member/search` - M11)
- **Tab 2: Schedule** (`/member/schedule` - Screen M20)
  - Session Detail modal/page (`/member/schedules/:id` - M17)
- **Tab 3: History** (`/member/attendance/history` - Screen M18)
  - Record Details (`/member/attendance/records/:id` - M19)
  - Attendance Calendar (`/member/attendance/calendar` - M18)
  - Attendance Totals (`/member/attendance/totals` - M21)
- **Tab 4: Requests** (`/member/requests` - Screen M28)
  - New Leave Request (`/member/requests/leave/new` - M26)
  - Attendance Correction (`/member/requests/correction/new` - M27)
  - Branch Transfer (`/member/transfer/new` - M31)
  - Transfer History (`/member/transfer/history` - M32)
- **Tab 5: Profile** (`/member/profile` - Screen M29)
  - Digital ID card (`/member/digital-id` - M22)
  - Edit Profile (`/member/profile/edit` - M30)
  - Class Info (`/member/classes/:id` - M23)
  - Department Info (`/member/department` - M24)
  - Branch Details (`/member/branch` - M25)
  - App Settings (`/member/settings` - M33)
  - Device Permissions (`/member/settings/permissions` - M35)
  - Help, Privacy & Support (`/member/settings/help` - M36)

---

## 2. Branch Manager Mobile Navigation

### Root Bottom Navigation Bar
- **Tab 1: Home** (`/manager/dashboard` - Screen BM07)
  - Quick Action: Create Invite Code (`/manager/invites/generate` - BM12)
  - Quick Action: View Members (`/manager/members` - BM08)
  - Quick Action: Attendance Logs (`/manager/attendance/logs` - BM13)
  - Quick Action: Send Announcement (`/manager/announcements/new` - BM15)
- **Tab 2: Members** (`/manager/members` - Screen BM08)
  - Member Details (`/manager/members/:id` - BM09)
  - Document Review (`/manager/members/:id/documents` - BM10)
  - Join Request Approvals (`/manager/requests/membership` - BM11)
  - Branch Members Overview (`/manager/members/overview` - BM23)
- **Tab 3: Attendance** (`/manager/attendance/logs` - Screen BM13)
  - Early Leave Queue (`/manager/requests/early-leave` - BM14)
  - Attendance Overview (`/manager/attendance/overview` - BM24)
  - Verification Logs (`/manager/logs/verification` - BM20)
- **Tab 4: Reports** (`/manager/reports` - Screen BM17)
- **Tab 5: More**
  - Schedule Management (`/manager/schedules` - BM16)
  - Leave Management (`/manager/requests/leave` - BM25)
  - Branch Settings (`/manager/settings/branch` - BM18)
  - Role Permissions (`/manager/settings/roles` - BM19)
  - Create / Edit Role (`/manager/roles/edit` - BM20)
  - Audit History (`/manager/logs/audit` - BM21)
  - Branch Messages (`/manager/messages` - BM22)
  - Branch Transfers (`/manager/requests/transfers` - BM27)

---

## 3. Web Admin Navigation (Sidebar Structure)

- **Overview**:
  - Dashboard (`/dashboard` - WA01)
  - Live Attendance (`/attendance/live` - WA02)
- **Attendance & Operations**:
  - Record Explorer (`/attendance/records/:id` - WA03)
  - Exceptions & Reviews (`/attendance/exceptions` - WA04)
  - Manual Corrections (`/attendance/corrections` - WA17)
- **Members & Enrollment**:
  - Member Directory (`/members` - WA05)
  - Join Requests & ID Review (`/members/requests` - WA06)
  - Profile & Permissions (`/members/:id/permissions` - WA07)
  - Class/Team Enrollments (`/organization/enrollments` - WA08)
  - Account Suspension (`/members/:id/status` - WA09)
- **Branches & Organization**:
  - Branch Directory (`/branches` - WA10)
  - Branch Geofence (`/branches/:id/geofence` - WA11)
  - Network Verification Setup (`/branches/:id/network` - WA12)
  - Branch Managers (`/branches/:id/managers` - WA13)
  - Classes & Teams (`/organization/groups` - WA18)
  - Departments (`/organization/departments` - WA19)
  - Responsibilities (`/organization/responsibilities` - WA20)
- **Policies & Schedules**:
  - Attendance Rules (`/policies/attendance` - WA14)
  - Schedule Windows (`/schedules/windows` - WA15)
  - Breaks & Duration (`/policies/breaks` - WA16)
- **Reports & Approvals**:
  - Analytics & Reports (`/reports` - WA21)
  - Export Center (`/exports` - WA22)
  - Leave & Correction Queue (`/approvals/requests` - WA23)
  - Branch Transfers (`/approvals/transfers` - WA24)
- **Security & Administration**:
  - Audit History (`/audit` - WA25)
  - Security Logs (`/security/logs` - WA26)
  - Operations & Settings (`/settings/operations` - WA27)
