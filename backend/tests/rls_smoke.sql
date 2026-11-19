-- Execute against disposable PostgreSQL after 0001_initial.sql.
-- Create fixtures as database administrator, but run assertions as app role.
BEGIN;
INSERT INTO app_users(id,email) VALUES
 ('11111111-1111-4111-8111-111111111111','alice@example.test'),
 ('22222222-2222-4222-8222-222222222222','bob@example.test');
INSERT INTO medications(id,user_id,name) VALUES
 ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  '11111111-1111-4111-8111-111111111111','Test medicine');
INSERT INTO dose_logs(id,medication_id,scheduled_for,recorded_at,status) VALUES
 ('cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  '2026-11-15T08:00:00Z','2026-11-15T08:05:00Z','taken');

CREATE ROLE meditrack_rls_test NOLOGIN;
GRANT USAGE ON SCHEMA public TO meditrack_rls_test;
GRANT SELECT, INSERT, UPDATE, DELETE ON medications, dose_logs TO meditrack_rls_test;
SET LOCAL ROLE meditrack_rls_test;

SELECT set_config('app.user_id','11111111-1111-4111-8111-111111111111',true);
DO $$
BEGIN
  IF (SELECT count(*) FROM medications) <> 1 THEN
    RAISE EXCEPTION 'Alice cannot see own medication';
  END IF;
  IF (SELECT count(*) FROM dose_logs) <> 1 THEN
    RAISE EXCEPTION 'Alice cannot see own dose';
  END IF;
END $$;

SELECT set_config('app.user_id','22222222-2222-4222-8222-222222222222',true);
DO $$
BEGIN
  IF (SELECT count(*) FROM medications) <> 0 THEN
    RAISE EXCEPTION 'Bob can see Alice medication';
  END IF;
  IF (SELECT count(*) FROM dose_logs) <> 0 THEN
    RAISE EXCEPTION 'Bob can see Alice dose';
  END IF;
  UPDATE medications SET name='tampered'
    WHERE id='aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
  IF FOUND THEN RAISE EXCEPTION 'Bob updated Alice medication'; END IF;
  DELETE FROM medications
    WHERE id='aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
  IF FOUND THEN RAISE EXCEPTION 'Bob deleted Alice medication'; END IF;
END $$;

DO $$
BEGIN
  BEGIN
    INSERT INTO medications(id,user_id,name) VALUES
      ('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
       '11111111-1111-4111-8111-111111111111','Forbidden');
    RAISE EXCEPTION 'Cross-user insert unexpectedly succeeded';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;
END $$;


-- A request without an authenticated account must see no records.
SELECT set_config('app.user_id','',true);
DO $$
BEGIN
  IF (SELECT count(*) FROM medications) <> 0 THEN
    RAISE EXCEPTION 'Unauthenticated access succeeded';
  END IF;
END $$;
ROLLBACK;
