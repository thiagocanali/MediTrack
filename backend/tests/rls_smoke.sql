-- Run after 0001_initial.sql, inside an isolated disposable database.
BEGIN;
INSERT INTO app_users(id,email) VALUES
 ('11111111-1111-4111-8111-111111111111','alice@example.test'),
 ('22222222-2222-4222-8222-222222222222','bob@example.test');

-- Exercise RLS as a non-owner, non-superuser application role.\nCREATE ROLE meditrack_rls_test NOLOGIN;\nGRANT USAGE ON SCHEMA public TO meditrack_rls_test;\nGRANT SELECT, INSERT, UPDATE, DELETE ON medications, dose_logs TO meditrack_rls_test;\nSET LOCAL ROLE meditrack_rls_test;\nSELECT set_config('app.user_id','11111111-1111-4111-8111-111111111111',true);
INSERT INTO medications(id,user_id,name) VALUES
 ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  '11111111-1111-4111-8111-111111111111','Test medicine');
DO $$
BEGIN
  IF (SELECT count(*) FROM medications) <> 1 THEN
    RAISE EXCEPTION 'Alice must see her medication';
  END IF;
END $$;
SELECT set_config('app.user_id','22222222-2222-4222-8222-222222222222',true);
DO $$
BEGIN
  IF (SELECT count(*) FROM medications) <> 0 THEN
    RAISE EXCEPTION 'Bob can see Alice medication';
  END IF;
END $$;
ROLLBACK;
