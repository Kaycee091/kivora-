# Email Delivery with Brevo SMTP

Supabase does **not** send any Kivora email. Supabase only stores user accounts. Verification
emails are sent by the Kivora web server (`web/admin`, Next.js) through Brevo SMTP, and every
setting comes from environment variables.

## How it works

```
Flutter app ──POST /api/auth/register──▶ web/admin server ──admin.createUser (sends no email)──▶ Supabase
                                               │
                                               ├─ generates a 6-digit code, stores an HMAC hash
                                               │  in public.email_verification_codes
                                               └─ sends the code via Brevo SMTP (nodemailer)
Flutter app ──POST /api/auth/verify-email──▶ checks the code ──admin.updateUserById(email_confirm)──▶ Supabase
Flutter app ──signInWithPassword──▶ Supabase (session)
```

| Endpoint | Body | Purpose |
|---|---|---|
| `POST /api/auth/register` | `{ email, password, fullName }` | Create an unverified account and email a code |
| `POST /api/auth/resend-code` | `{ email }` | Email a new code (60 s cooldown) |
| `POST /api/auth/verify-email` | `{ email, code }` | Confirm the account (10 min expiry, 5 attempts) |
| `GET /api/email/status` | – | Health check: checks that Brevo accepts your SMTP login |

Sign-in with an unverified account automatically sends a new code and opens the verify screen.

## 1. Brevo: get SMTP credentials

1. Brevo → profile menu (top right) → **SMTP & API** → **SMTP** tab.
2. Copy the **Login** (looks like `8a1b2c001@smtp-brevo.com`; this is not your account email).
3. **Generate a new SMTP key** → name it `kivora` → copy it (`xsmtpsib-...`). It is shown once.
   An API key (`xkeysib-...`) will **not** work for SMTP.

## 2. Brevo: verify the sender

1. **Senders, Domains & Dedicated IPs** → **Senders** → **Add a sender** (e.g.
   `notifications@yourdomain.com`) → confirm via the email Brevo sends.
2. Recommended: **Domains** → add your domain and the DKIM / DMARC / Brevo-code DNS records,
   otherwise Gmail and Yahoo may send the mail to spam or reject it.

## 3. One-time database step

Apply `server/supabase/migrations/00010_email_verification_codes.sql` to your project, either with
`supabase db push --linked`, or by pasting it into Supabase Dashboard → **SQL Editor** → Run.

## 4. Environment variables

These go on the **web/admin server**: `web/admin/.env.local` locally, or your host's env settings.

| Variable | Required | Value |
|---|:---:|---|
| `NEXT_PUBLIC_SUPABASE_URL` | Yes | `https://bbgecpfqfoqlmzzbfeyu.supabase.co` |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Yes | Supabase publishable/anon key |
| `SUPABASE_SERVICE_ROLE_KEY` | Yes | Supabase → Project Settings → API Keys → `service_role` / secret key. **Server only.** |
| `BREVO_SMTP_HOST` | No | `smtp-relay.brevo.com` (default) |
| `BREVO_SMTP_PORT` | No | `587` (default; `465` for implicit TLS, `2525` if 587 is blocked) |
| `BREVO_SMTP_USER` | Yes | Brevo SMTP login |
| `BREVO_SMTP_KEY` | Yes | Brevo SMTP key `xsmtpsib-...` |
| `EMAIL_FROM_ADDRESS` | Yes | Your verified Brevo sender |
| `EMAIL_FROM_NAME` | No | `Kivora` (default) |
| `EMAIL_OTP_SECRET` | No | Random secret for hashing codes; defaults to the service role key |
| `CORS_ALLOWED_ORIGINS` | Yes* | URL(s) of the Flutter web app, comma-separated. *Needed for Flutter **web** only |

The **Flutter app** needs the server URL at build/run time:

```bash
flutter run -d chrome --dart-define=KIVORA_API_URL=http://localhost:3000
flutter build web --dart-define=KIVORA_API_URL=https://admin.yourdomain.com
```

(It defaults to `http://localhost:3000`. On an Android emulator use `http://10.0.2.2:3000`.)

### Local

1. Fill in the blank values in `web/admin/.env.local` (the file is git-ignored).
2. Restart: `cd web/admin && pnpm dev`.
3. Check: open http://localhost:3000/api/email/status. You should see `{"ok":true,...}`.

### Hosting (e.g. Vercel)

1. Project → **Settings** → **Environment Variables** → add every variable from the table above
   (mark `SUPABASE_SERVICE_ROLE_KEY`, `BREVO_SMTP_KEY` and `EMAIL_OTP_SECRET` as sensitive).
2. Set `CORS_ALLOWED_ORIGINS` to your deployed Flutter web URL.
3. Redeploy, then open `https://<your-admin-domain>/api/email/status`.

Other Node hosts (Netlify, Render, Railway, a VPS) work the same way: set the same variables in
their dashboard or `.env`. The host must allow outbound SMTP on port 587, 465 or 2525. (Supabase
Edge Functions block 587, which is one reason this runs in the Next.js server.)

## 5. Supabase dashboard settings

- Leave **Authentication → Sign In / Providers → Email → Confirm email** **on**. This blocks
  unverified users from signing in until they enter the Brevo code.
- Custom SMTP in Supabase is **not** needed and can stay off.

## 6. Test

1. Open the Flutter app → **Register** with a real inbox.
2. The "Your Kivora verification code" email arrives from your Brevo sender.
3. Enter the code. You're signed in and taken to the branch gateway.

Troubleshooting:
- `/api/email/status` shows `Brevo rejected the SMTP login/key`: wrong `BREVO_SMTP_USER` or
  `BREVO_SMTP_KEY`.
- `Email service is not configured on the server`: a required variable is missing. The server log
  names it.
- `get_auth_user_by_email failed`: the migration in step 3 hasn't been applied.
- Flutter web `ClientException: Failed to fetch`: the server isn't running, or the app's origin
  is missing from `CORS_ALLOWED_ORIGINS`.
- Brevo → **Transactional** → **Logs** shows every delivery, bounce and block.

Brevo free plan: 300 emails/day. Brevo SMTP only sends mail; Kivora has no inbound email feature.
