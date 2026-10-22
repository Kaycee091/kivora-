# Kivora Comprehensive Testing Strategy

## 1. Testing Layers

### 1. Unit & Schema Tests
- **Database / Backend**:
  - Verification that RLS policies prevent unauthorized SELECT / INSERT / UPDATE across branch boundaries.
  - Foreign key and check constraint integrity tests.
  - Edge Function validation tests (Zod schemas, error handling, date math).
- **Web Admin**:
  - Vitest unit tests for date formatting, permission guards, filter calculations, and form validation schemas.
- **Mobile (Flutter)**:
  - Unit tests for Riverpod providers, model JSON serialization, attendance state machines, and repository contracts.

### 2. Component & Widget Tests
- **Web Admin**:
  - React Testing Library tests for tables, pagination, modal dialogs, status chips, and confirmation flows.
- **Mobile (Flutter)**:
  - Widget tests for design system buttons, text fields, verification checklists, and attendance status cards.

### 3. End-to-End (E2E) Workflows
- **Web Admin (Playwright)**:
  - Admin login -> View Live Attendance -> Approve join request -> Export reports.
- **Mobile Integration Tests**:
  - Sign in -> View Home -> Start check-in -> Verification outcome flow.

## 2. Automated Test Execution Commands
- **Monorepo Suite**: `pnpm test:all`
- **Web Admin Unit Tests**: `pnpm --filter @kivora/web-admin test`
- **Web Admin E2E Tests**: `pnpm --filter @kivora/web-admin test:e2e`
- **Flutter Analysis & Tests**:
  ```bash
  cd app
  flutter analyze
  flutter test
  ```
