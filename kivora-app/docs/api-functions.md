# Kivora Edge Functions & API Contract Specification

Edge Functions are implemented in TypeScript under `server/supabase/functions/` and executed in the Deno runtime with Zod validation.

---

## 1. Edge Function Inventory

### 1. `attendance-check-in`
- **Method**: `POST`
- **Auth**: Required (Bearer JWT)
- **Input**:
  ```json
  {
    "session_id": "UUID",
    "verification_evidence": {
      "biometric_verified": true,
      "latitude": 6.5244,
      "longitude": 3.3792,
      "accuracy_meters": 12.5,
      "network_bssid": "optional_hash",
      "client_ip": "optional_string"
    }
  }
  ```
- **Validation**: Verifies user assignment to session, verifies session window, calculates GPS distance against branch center, evaluates overall status (`passed`, `failed`, `needs_review`).
- **Response**: `{ "record_id": "UUID", "status": "present", "verification_status": "passed", "server_timestamp": "ISO8601" }`

### 2. `attendance-check-out`
- **Method**: `POST`
- **Auth**: Required
- **Input**: `{ "record_id": "UUID" }`
- **Validation**: Verifies existing active check-in for caller, computes duration, writes checkout event.
- **Response**: `{ "record_id": "UUID", "duration_seconds": 28800, "check_out_time": "ISO8601" }`

### 3. `submit-membership-request`
- **Method**: `POST`
- **Input**: `{ "branch_code": "STRING", "requested_role": "STRING", "notes": "STRING" }`
- **Response**: `{ "request_id": "UUID", "status": "pending" }`

### 4. `review-membership-request`
- **Method**: `POST`
- **Auth**: Requires `members.approve_join_request` on target branch
- **Input**: `{ "request_id": "UUID", "action": "approve | reject | request_info", "reason": "STRING" }`
- **Response**: `{ "status": "approved", "assignment_id": "UUID" }`

### 5. `review-identity-document`
- **Method**: `POST`
- **Auth**: Requires `members.review_identity_docs` on branch
- **Input**: `{ "document_id": "UUID", "status": "reviewed | rejected | needs_resubmission", "reason": "STRING" }`

### 6. `submit-leave-request`
- **Method**: `POST`
- **Input**: `{ "branch_id": "UUID", "leave_type": "STRING", "start_date": "ISO8601", "end_date": "ISO8601", "reason": "STRING", "session_id": "optional_UUID" }`

### 7. `submit-attendance-correction`
- **Method**: `POST`
- **Input**: `{ "record_id": "UUID", "proposed_check_in": "ISO8601", "proposed_check_out": "ISO8601", "reason": "STRING" }`

### 8. `submit-branch-transfer`
- **Method**: `POST`
- **Input**: `{ "target_branch_id": "UUID", "reason": "STRING" }`

### 9. `review-branch-transfer`
- **Method**: `POST`
- **Auth**: Branch manager or web admin
- **Input**: `{ "transfer_id": "UUID", "action": "approve | reject", "reason": "STRING" }`

### 10. `manage-schedule`
- **Method**: `POST`
- **Auth**: Requires `schedules.create_session`
- **Input**: `{ "branch_id": "UUID", "class_id": "UUID", "title": "STRING", "start_time": "ISO8601", "end_time": "ISO8601", "assigned_user_ids": ["UUID"] }`

### 11. `send-announcement`
- **Method**: `POST`
- **Auth**: Requires `announcements.create`
- **Input**: `{ "branch_id": "UUID", "target_role": "STRING", "title": "STRING", "content": "STRING" }`

### 12. `create-export`
- **Method**: `POST`
- **Auth**: Requires `reports.export_data`
- **Input**: `{ "branch_id": "UUID", "format": "csv | xlsx | pdf", "date_from": "ISO8601", "date_to": "ISO8601" }`
- **Audit**: Writes download event to `audit_logs`

### 13. `manage-account-status`
- **Method**: `POST`
- **Auth**: Requires `members.suspend_account`
- **Input**: `{ "user_id": "UUID", "status": "suspended | active", "reason": "STRING" }`
- **Audit**: Writes audit log with actor ID and reason.
