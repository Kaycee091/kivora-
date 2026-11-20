# Kivora Environment Variables Specification

This document details all configuration parameters across the client and server applications.

---

## 1. Public Variables (Web Admin & Mobile Clients)

| Variable Name | Required | Target | Description | Example |
|---|:---:|---|---|---|
| `NEXT_PUBLIC_SUPABASE_URL` | Yes | Web Admin | Public endpoint of the Supabase project | `https://xyzcompany.supabase.co` |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Yes | Web Admin | Public anonymous client key (subject to RLS) | `eyJhbGciOiJIUz...` |
| `SUPABASE_URL` / `FLUTTER_APP_SUPABASE_URL` | Yes | Mobile (`--dart-define`) | Public endpoint for Flutter Supabase client | `https://xyzcompany.supabase.co` |
| `SUPABASE_ANON_KEY` / `SUPABASE_PUBLISHABLE_KEY` | Yes | Mobile (`--dart-define`) | Public anon or publishable key for Flutter Supabase client | `eyJhbGciOiJIUz...` |

---

## 2. Server-Only Secrets (Edge Functions & Scripts)
**NEVER commit or bundle these variables in client applications!**

| Variable Name | Required | Target | Description |
|---|:---:|---|---|
| `SUPABASE_URL` | Yes | Edge Functions | Internal project URL |
| `SUPABASE_SERVICE_ROLE_KEY` | Yes | Edge Functions | Privileged service key bypassing RLS for administrative jobs |
| `SUPABASE_DB_PASSWORD` | Optional | Migrations / CLI | Direct PostgreSQL connection password |
| `SMTP_HOST` | Optional | Server notifications | Hostname for outgoing email server |
| `SMTP_USER` | Optional | Server notifications | Username for SMTP service |
| `SMTP_PASSWORD` | Optional | Server notifications | Password for SMTP service |
