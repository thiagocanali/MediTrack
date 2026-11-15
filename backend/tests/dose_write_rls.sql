-- Run in disposable PostgreSQL after migrations 0001 and 0002.
BEGIN;
INSERT INTO app_users(id,email) VALUES
 ('44444444-4444-4444-8444-444444444444','dose-a@example.test'),
 ('55555555-5555-4555-8555-555555555555','dose-b@example.test');
INSERT INTO medications(id,user_id,name) VALUES
 ('aaaaaaaa-bbbb-4ccc-8ddd-eeeeeeeeeeee',
  '44444444-4444-4444-8444-444444444444','Owned medication');
CREATE ROLE meditrack_dose_test NOLOGIN;
GRANT USAGE ON SCHEMA public TO meditrack_dose_test;
GRANT SELECT, INSERT, UPDATE, DELETE ON medications, dose_logs TO meditrack_dose_test;
SET LOCAL ROLE meditrack_dose_test;
SELECT set_config('app.user_id','55555555-5555-4555-8555-555555555555',true);
DO $$
BEGIN
  BEGIN
    INSERT INTO dose_logs(id,medication_id,scheduled_for,recorded_at,status)
    VALUES ('99999999-9999-4999-8999-999999999999',
      'aaaaaaaa-bbbb-4ccc-8ddd-eeeeeeeeeeee',
      '2026-11-15 08:00:00+00','2026-11-15 08:05:00+00','taken');
    RAISE EXCEPTION 'Cross-user dose insertion succeeded';
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;
END $$;
ROLLBACK;
