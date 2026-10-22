# Kivora Live Implementation Roadmap & Progress Tracker

## Phase Status Summary

- [x] **Phase 1: Inspect & Plan**: Inspected both PDF references (`Kivora_Complete_App_Designs-1(1).pdf` and `Kivora_Client_Friendly_PRD_v4(1).pdf`), reconciled business rules, cataloged all 90 screens + 10 onboarding flows, established the unified database schema, permissions matrix, and design tokens.
- [x] **Phase 2: Workspace Foundations**:
  - [x] Initialized root `kivora-app` structure with `web/admin`, `app`, `server`, `docs`, `scripts`.
  - [x] Configured monorepo tools: `package.json`, `pnpm-workspace.yaml`, `.gitignore`, `.editorconfig`, `.env.example`.
  - [x] Verified and validated workspace structure with automated scripts.
- [ ] **Phase 3: Database & Backend Foundations**:
  - [ ] Write PostgreSQL migration scripts with foreign keys, constraints, and indexes.
  - [ ] Implement Row Level Security (RLS) policies for tenant isolation.
  - [ ] Implement TypeScript Edge Functions with Zod validation.
  - [ ] Create development seed data with realistic fictional entities.
- [ ] **Phase 4: Design System & Application Shells**:
  - [ ] Implement Flutter theme, tokens, and reusable widgets (`KivoraTheme`, buttons, inputs, cards, status chips).
  - [ ] Implement Next.js Shadcn layout, navigation sidebar, topbar, and theme providers.
  - [ ] Set up GoRouter role-aware navigation for member and branch manager flows.
- [ ] **Phase 5: Authentication & Onboarding Workflows**:
  - [ ] Implement sign-in, account creation, and 6-digit OTP email verification.
  - [ ] Implement branch invite code validation and join request submission.
  - [ ] Implement manager review and approval workflows.
- [ ] **Phase 6: Core Attendance & Verification Engine**:
  - [ ] Implement check-in and check-out logic with biometric, GPS geofence, and network checks.
  - [ ] Enforce the 4-state verification model (`PASSED`, `FAILED`, `UNAVAILABLE`, `NEEDS_REVIEW`).
  - [ ] Build member attendance history, calendar, and totals.
- [ ] **Phase 7: Requests & Branch Operations**:
  - [ ] Implement leave, early departure, and attendance correction workflows.
  - [ ] Implement branch transfer requests with destination review.
  - [ ] Implement schedule and session management.
- [ ] **Phase 8: Reports, Exports & Communications**:
  - [ ] Implement manager and admin reporting dashboards.
  - [ ] Implement secure CSV/PDF export generation with audit logging.
  - [ ] Implement announcements and in-app notifications.
- [ ] **Phase 9: Settings, Profile & Digital ID**:
  - [ ] Implement digital ID card with QR code.
  - [ ] Implement profile editing, security settings, and device permission guidance.
- [ ] **Phase 10: End-to-End Verification & Quality**:
  - [ ] Execute automated tests across web, backend, and mobile.
  - [ ] Verify complete user journeys and branch data isolation.
