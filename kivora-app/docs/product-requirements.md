# Kivora Product Requirements Document (PRD)

## 1. Product Summary
- **Product Name**: Kivora
- **Core Function**: Enterprise membership management, branch administration, scheduled sessions, attendance verification (device biometric prompt, GPS geofence, network verification), exception reporting, and auditable requests.
- **Client Applications**:
  1. **Member Mobile App** (Flutter - iOS/Android)
  2. **Branch Manager Mobile App** (Flutter - iOS/Android)
  3. **Web Administration Dashboard** (Next.js - Desktop Web)
- **Authoritative Backend**: Central PostgreSQL instance managed via Supabase with Row Level Security (RLS) and TypeScript Edge Functions.

## 2. Business Objectives & Principles
1. **Single Source of Truth**: All mobile clients and the web administration portal access the exact same authoritative backend database and business logic.
2. **Branch Isolation**: Organizations and branches maintain strict data boundaries. A member or branch manager cannot view or mutate data belonging to an unrelated branch or user.
3. **One Active Branch Rule**: Ordinary members belong to exactly one active branch at a time. Transitions between branches require an auditable transfer workflow.
4. **Authoritative Server Time**: Client device clocks are treated as untrusted. All attendance events and verification records record official server timestamps.
5. **No Destructive Overwrites**: Attendance history, corrections, leave decisions, and audit entries are immutable. Corrections link to original events rather than overwriting them.
6. **Multi-Factor Verification States**:
   - Verification outcomes must strictly map to one of four states:
     - `PASSED`
     - `FAILED`
     - `UNAVAILABLE`
     - `NEEDS_REVIEW`
   - No arbitrary confidence percentages or fake match probabilities are permitted.

## 3. Reference Analysis & Conflict Resolution
- Source PDF 1: `Kivora_Complete_App_Designs-1(1).pdf` (73 total screen concepts)
- Source PDF 2: `Kivora_Client_Friendly_PRD_v4(1).pdf` (Product rules, architecture, scope)

### Appendix B Reconciliations
- **Account Creation**: Registration does not force a Student/Teacher choice. Role selection occurs when submitting a branch membership join request.
- **Registration Success**: Do not display a generic "Awaiting Approval" screen immediately upon account creation. Awaiting approval is only shown after the user submits a branch join request.
- **Identity Documents**: Stored in private storage buckets and labeled as "Reviewed" by authorized reviewers; not misrepresented as legal identity proof.
- **QR Codes**: QR codes provide quick record lookup; scanning alone does not constitute attendance proof.
