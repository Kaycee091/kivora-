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

---

## 3. Email (Brevo SMTP, web/admin server only)

Supabase sends no email. The web/admin server sends verification codes through Brevo.
Full guide: [email-brevo-setup.md](./email-brevo-setup.md).

| Variable Name | Required | Description |
|---|:---:|---|
| `SUPABASE_SERVICE_ROLE_KEY` | Yes | Creates accounts / confirms emails via the admin API |
| `BREVO_SMTP_HOST` | No | Defaults to `smtp-relay.brevo.com` |
| `BREVO_SMTP_PORT` | No | Defaults to `587` |
| `BREVO_SMTP_USER` | Yes | Brevo SMTP login (`xxxx@smtp-brevo.com`) |
| `BREVO_SMTP_KEY` | Yes | Brevo SMTP key (`xsmtpsib-...`) |
| `EMAIL_FROM_ADDRESS` | Yes | Sender verified in Brevo |
| `EMAIL_FROM_NAME` | No | Defaults to `Kivora` |
| `EMAIL_OTP_SECRET` | No | HMAC secret for codes; defaults to the service role key |
| `CORS_ALLOWED_ORIGINS` | Yes (Flutter web) | Comma-separated origins allowed to call `/api/auth/*` |
| `KIVORA_API_URL` | Yes (Flutter, `--dart-define`) | Base URL of the web/admin server; defaults to `http://localhost:3000` |
