# Kivora Authoritative Business Rules

## 1. Membership & Scope
1. **One Active Branch**: An ordinary member may possess only one active record in `user_branch_assignments` at any given time.
2. **Transfer Preconditions**: When an approved transfer request is applied:
   - The prior assignment is marked inactive (`effective_to = now()`, `is_active = false`).
   - The new branch assignment is created as active.
   - All historical attendance records remain permanently associated with the original branch where they were logged.
3. **Join Request Lifecycle**:
   - `pending` -> `approved` (creates active branch assignment).
   - `pending` -> `rejected` (requires recorded rejection reason).
   - `pending` -> `needs_information` (user prompted to upload supplementary documents or clarify fields).

## 2. Attendance & Verification Lifecycle
1. **Session Window Rules**:
   - Members may only initiate check-in within the configured window (`start_time - check_in_window_minutes_before` through `end_time`).
   - If check-in occurs after `start_time + grace_period_minutes`, the record status is set to `late`.
2. **Verification Logic**:
   - **Local Biometrics**: Must be executed on the physical device via native OS prompts (`local_auth`). A cryptographic or signed validation flag is transmitted; raw biometric data is never transmitted or retained.
   - **GPS Geofence**: Server calculates Haversine distance between client coordinates and branch coordinates. If distance <= `geofence_radius_meters`, GPS check is `passed`; otherwise `failed`.
   - **Network Check**: Verified against branch trusted subnet/IP configuration.
   - **Status Mapping**:
     - All required factors pass -> `overall_verification_status = 'passed'`, `status = 'present'` (or `late`).
     - Any required factor fails with acceptable accuracy/permission error -> `needs_review`.
     - Hard mismatch / out of range -> `failed`.
     - Factor not enabled on device or platform -> `unavailable`.
3. **No Overwrites / Immutable Events**:
   - Any check-in or check-out attempt appends an immutable entry to `attendance_events`.
   - Attendance corrections do not modify the original check-in timestamp; they record `proposed_check_in`, `reviewed_by`, and append an `attendance_events` record of type `correction_applied`.

## 3. Leave & Early Departure
1. Leave requests require start and end dates within the future or permissible backfill window.
2. Early departure requests require an existing check-in on the target session and require manager review before the departure is marked excused.
