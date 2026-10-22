# Kivora Monorepo

Kivora is an enterprise-grade membership management, branch administration, scheduling, attendance tracking, multi-factor verification, reporting, and administrative operations platform.

## System Components

1. **Member Mobile Application** (`app/`): Flutter (iOS & Android) for students, employees, and members.
2. **Branch Manager Mobile Application** (`app/`): Flutter (iOS & Android) with branch-scoped administrative features.
3. **Web Administration Dashboard** (`web/admin/`): Next.js App Router, TypeScript, Tailwind CSS, TanStack Query/Table, and Shadcn UI.
4. **Authoritative Backend** (`server/`): PostgreSQL, Supabase Auth, Row Level Security (RLS), and TypeScript Edge Functions.

## Directory Structure

```text
kivora-app/
├── web/
│   └── admin/          # Next.js web admin portal
├── app/                # Flutter mobile application (Member & Branch Manager)
├── server/             # Supabase migrations, Edge Functions, seeds, and backend tests
├── docs/               # Comprehensive system documentation and traceability
├── scripts/            # Quality, workspace validation, and environment verification scripts
├── package.json        # Root pnpm monorepo configuration
├── pnpm-workspace.yaml # Workspace definitions
└── README.md
```

## Quick Start

### Prerequisites
- Node.js >= 20.x (Current: v22.13.1)
- pnpm >= 9.x (Current: v10.15.0)
- Flutter SDK >= 3.24.x
- Git >= 2.40.x

### Web Admin
```bash
cd web/admin
pnpm install
pnpm dev
```

### Mobile App (Flutter)
```bash
cd app
flutter pub get
flutter run
```

### Backend (Supabase)
```bash
cd server
supabase start
supabase db reset
```
