# Kivora System Architecture

## 1. High-Level Architecture Overview

```text
+-------------------------+      +-------------------------------+      +-------------------------+
|   Member Mobile App     |      | Branch Manager Mobile App     |      |    Web Admin Portal     |
|     (Flutter/Dart)      |      |        (Flutter/Dart)         |      |    (Next.js/React/TS)   |
+------------+------------+      +---------------+---------------+      +------------+------------+
             |                                   |                                   |
             | HTTPS / WSS                       | HTTPS / WSS                       | HTTPS / WSS
             +-----------------+                 |                 +-----------------+
                               |                 |                 |
                               v                 v                 v
                 +-------------------------------------------------------------+
                 |                     SUPABASE API GATEWAY                    |
                 |     (JWT Authentication, Rate Limiting, CORS, Realtime)      |
                 +-----------------------------+-------------------------------+
                                               |
         +-------------------------------------+-------------------------------------+
         |                                                                           |
         v                                                                           v
+-------------------------------+                                           +-------------------------------+
|      POSTGRESQL DATABASE      |                                           |    TYPESCRIPT EDGE FUNCTIONS  |
|  - Relational Schemas         |                                           |  - attendance-check-in        |
|  - Row Level Security (RLS)   |<------------------------------------------|  - attendance-check-out       |
|  - Foreign Keys & Constraints |        Internal Direct SQL / PostgREST    |  - submit-membership-request  |
|  - Audit & Verification Logs  |                                           |  - review-membership-request  |
+---------------+---------------+                                           |  - review-identity-document   |
                |                                                           |  - submit-leave-request       |
                v                                                           |  - submit-attendance-correct  |
+-------------------------------+                                           |  - submit-branch-transfer     |
|   SUPABASE PRIVATE STORAGE    |                                           |  - review-branch-transfer     |
|  - identity_documents/        |                                           |  - manage-schedule            |
|  - profile_avatars/           |                                           |  - create-export              |
|  (Time-limited Signed URLs)   |                                           |  - manage-account-status      |
+-------------------------------+                                           +-------------------------------+
```

## 2. Trust Boundaries & Principles
1. **Client Apps are Untrusted**: Mobile and web clients cannot directly execute SQL updates to official attendance, approval decisions, or role definitions.
2. **Authoritative Timestamping**: Check-in, check-out, and audit timestamps are strictly assigned on the server via `NOW()` / `timezone('utc', now())`.
3. **Branch Scoping**: All queries and mutations are filtered by `branch_id`. Branch managers cannot read or manipulate data outside their assigned branch scopes.
4. **Row Level Security (RLS)**: Enforced directly on the database engine. Even if client code is manipulated, RLS prevents cross-tenant data leakage.
5. **No Secret Keys in Client Applications**: `SUPABASE_SERVICE_ROLE_KEY` is strictly confined to server-side Edge Functions and protected deployment environments. Clients receive only the public `anon` key.
