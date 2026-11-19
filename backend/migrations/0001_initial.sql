-- MediTrack PostgreSQL schema foundation (not applied to production).
-- The backend authenticates requests and resolves the account UUID from
-- its trusted session. Never accept account_id from a mobile request body.
BEGIN;

CREATE TABLE IF NOT EXISTS app_users (
  id uuid PRIMARY KEY,
  email text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT app_users_email_nonblank CHECK (length(trim(email)) > 3)
);
CREATE UNIQUE INDEX IF NOT EXISTS app_users_email_unique
  ON app_users (lower(email));

CREATE TABLE IF NOT EXISTS medications (
  id uuid PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES app_users(id) ON DELETE RESTRICT,
  name text NOT NULL,
  dosage text,
  instructions text,
  active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT medications_name_nonblank CHECK (length(trim(name)) > 0)
);
CREATE INDEX IF NOT EXISTS medications_user_active_idx
  ON medications(user_id, active, created_at DESC);

CREATE TABLE IF NOT EXISTS dose_logs (
  id uuid PRIMARY KEY,
  medication_id uuid NOT NULL REFERENCES medications(id) ON DELETE RESTRICT,
  scheduled_for timestamptz NOT NULL,
  recorded_at timestamptz NOT NULL DEFAULT now(),
  status text NOT NULL CHECK (status = 'taken'),
  CONSTRAINT dose_logs_unique_occurrence UNIQUE (medication_id, scheduled_for),
  CONSTRAINT dose_logs_time_order CHECK (recorded_at >= scheduled_for)
);
CREATE INDEX IF NOT EXISTS dose_logs_medication_recent_idx
  ON dose_logs(medication_id, scheduled_for DESC);

-- Defense in depth: backend must set app.user_id in each transaction.
-- No table grants to the anonymous/public database roles.
ALTER TABLE medications ENABLE ROW LEVEL SECURITY;
ALTER TABLE medications FORCE ROW LEVEL SECURITY;
ALTER TABLE dose_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE dose_logs FORCE ROW LEVEL SECURITY;

CREATE POLICY medications_owner ON medications
  FOR ALL USING (user_id = nullif(current_setting('app.user_id', true), '')::uuid)
  WITH CHECK (user_id = nullif(current_setting('app.user_id', true), '')::uuid);

CREATE POLICY dose_logs_owner ON dose_logs
  FOR ALL USING (
    EXISTS (SELECT 1 FROM medications m WHERE m.id = medication_id
      AND m.user_id = nullif(current_setting('app.user_id', true), '')::uuid)
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM medications m WHERE m.id = medication_id
      AND m.user_id = nullif(current_setting('app.user_id', true), '')::uuid)
  );

COMMIT;
