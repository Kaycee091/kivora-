# Kivora Security, Permissions & Privacy Architecture

## 1. Authentication & Session Management
- **Identity Provider**: Supabase Auth handles password hashing (bcrypt/argon2), JWT issuance, and email confirmation flows.
- **Tokens**: Clients store JWTs securely (`flutter_secure_storage` on mobile, HTTP-only cookie or secure local storage for web).
- **Service Role Key Security**: `SUPABASE_SERVICE_ROLE_KEY` is strictly prohibited in client bundles, Flutter repositories, and public environment files. It is only accessible to trusted backend Edge Functions.

## 2. Row Level Security (RLS) Strategy
Every application table enables RLS:
```sql
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE branches ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_branch_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE leave_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
```

### Core Policy Patterns
1. **User Ownership**: Users may read and update their own `profiles` record:
   ```sql
   CREATE POLICY "Users can read own profile" ON profiles FOR SELECT USING (auth.uid() = id);
   ```
2. **Branch Scoping**: Members and managers can only read records belonging to their active assigned branch:
   ```sql
   CREATE POLICY "Branch member attendance access" ON attendance_records FOR SELECT USING (
     user_id = auth.uid() OR
     EXISTS (
       SELECT 1 FROM user_branch_assignments uba
       WHERE uba.user_id = auth.uid()
       AND uba.branch_id = attendance_records.branch_id
       AND uba.is_active = true
       AND uba.role IN ('branch_manager', 'branch_admin', 'web_admin')
     )
   );
   ```
3. **Audit Log Protection**: `audit_logs` and `verification_logs` are strictly append-only. No `UPDATE` or `DELETE` policies are defined.

## 3. Privacy & Sensitive Data Handling
1. **Biometric Privacy**: Kivora never captures, transmits, or stores raw biometric images (fingerprints, face geometry, irises). The native operating system performs authentication and yields only a boolean verification signal.
2. **Location Privacy**: Latitude and longitude are captured solely at the moment of check-in to compute proximity to branch coordinates. Real-time background tracking is prohibited.
3. **Identity Document Retention**: Files uploaded to `identity_documents` reside in an encrypted private Supabase Storage bucket. Access requires signed URLs with an expiration lifetime of <= 15 minutes.
