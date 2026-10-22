# Kivora Permissions Matrix

Access control in Kivora combines **Role Assignment** with **Branch Scope**.

## Roles
- `member`: Standard attendee (student, teacher, worker, employee).
- `branch_manager`: Operational lead for one or more specific branches.
- `branch_admin`: Administrative manager for a branch.
- `web_admin`: System/organization administrator for management & oversight.

---

## Action Permissions by Role

| Permission Identifier | Description | Member | Branch Manager | Branch Admin | Web Admin |
|---|---|:---:|:---:|:---:|:---:|
| `attendance.check_in` | Perform personal check-in | [x] | [x] | [x] | [ ] |
| `attendance.check_out` | Perform personal check-out | [x] | [x] | [x] | [ ] |
| `attendance.view_own` | View personal attendance & totals | [x] | [x] | [x] | [ ] |
| `attendance.view_branch_logs` | View branch attendance logs | [ ] | [x] | [x] | [x] |
| `attendance.review_exceptions` | Review and resolve failed checks | [ ] | [x] | [x] | [x] |
| `attendance.submit_correction` | Request correction for a session | [x] | [x] | [x] | [ ] |
| `attendance.review_correction` | Approve or reject correction request | [ ] | [x] | [x] | [x] |
| `members.view_roster` | View list of branch members | [ ] | [x] | [x] | [x] |
| `members.review_identity_docs` | Review uploaded ID documents | [ ] | [x] | [x] | [x] |
| `members.approve_join_request` | Approve/reject branch join requests | [ ] | [x] | [x] | [x] |
| `members.suspend_account` | Suspend or reactivate member account | [ ] | [ ] | [x] | [x] |
| `branches.create_invite_code` | Generate branch invitation codes | [ ] | [x] | [x] | [x] |
| `branches.manage_settings` | Edit geofence, address, details | [ ] | [ ] | [x] | [x] |
| `schedules.create_session` | Create classes or shift sessions | [ ] | [x] | [x] | [x] |
| `schedules.assign_members` | Assign members/groups to sessions | [ ] | [x] | [x] | [x] |
| `requests.submit_leave` | Submit leave or early departure | [x] | [x] | [x] | [ ] |
| `requests.review_leave` | Approve or reject leave requests | [ ] | [x] | [x] | [x] |
| `transfers.request_transfer` | Submit branch transfer application | [x] | [ ] | [ ] | [ ] |
| `transfers.review_transfer` | Review and execute branch transfer | [ ] | [x] | [x] | [x] |
| `announcements.create` | Broadcast announcement to branch | [ ] | [x] | [x] | [x] |
| `reports.view_branch` | View aggregated attendance reports | [ ] | [x] | [x] | [x] |
| `reports.export_data` | Export PDF, CSV, XLSX datasets | [ ] | [x] | [x] | [x] |
| `audit.view_logs` | View immutable administrative logs | [ ] | [x] | [x] | [x] |
| `roles.manage_permissions` | Configure custom role definitions | [ ] | [ ] | [x] | [x] |
