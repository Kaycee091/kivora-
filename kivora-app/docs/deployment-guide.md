# Kivora Deployment Guide

## 1. Local Development Environment Setup

### 1. Web Admin (Next.js)
```bash
cd web/admin
pnpm install
pnpm dev
# Runs local development server at http://localhost:3000
```

### 2. Backend (Supabase Local Development)
```bash
cd server
supabase start
supabase db reset # Applies all migrations and dev seed data
```

### 3. Mobile App (Flutter)
```bash
cd app
flutter pub get
flutter run -d chrome # or android / ios simulator
```

## 2. Staging & Production Deployment

### Web Admin
- Build command: `pnpm build`
- Deploy target: Vercel or AWS Amplify / Cloudflare Pages.
- Configure production environment variables (`NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`).

### Server & Database
- Apply versioned migrations sequentially via Supabase CLI:
  ```bash
  supabase db push --linked
  ```
- Deploy Edge Functions:
  ```bash
  supabase functions deploy attendance-check-in
  supabase functions deploy attendance-check-out
  supabase functions deploy submit-membership-request
  supabase functions deploy review-membership-request
  supabase functions deploy review-identity-document
  supabase functions deploy submit-leave-request
  supabase functions deploy submit-attendance-correction
  supabase functions deploy submit-branch-transfer
  supabase functions deploy review-branch-transfer
  supabase functions deploy manage-schedule
  supabase functions deploy send-announcement
  supabase functions deploy create-export
  supabase functions deploy manage-account-status
  ```

### Mobile App Deployment
- Android: Build Signed App Bundle (`flutter build appbundle --release`).
- iOS: Build IPA via Xcode / Fastlane (`flutter build ipa --release`).
