-- Disposable PostgreSQL only; migration 0001 and 0002 already applied.
BEGIN;
INSERT INTO app_users(id,email) VALUES
 ('33333333-3333-4333-8333-333333333333','case@example.test');
INSERT INTO medications(id,user_id,name) VALUES
 ('eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
  '33333333-3333-4333-8333-333333333333','Medication');
INSERT INTO dose_logs(id,medication_id,scheduled_for,recorded_at,status) VALUES
 ('ffffffff-ffff-4fff-8fff-ffffffffffff',
  'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
  '2026-11-15 08:00:00+00','2026-11-15 08:01:00+00','taken');
DO $$
BEGIN
  BEGIN
    INSERT INTO dose_logs(id,medication_id,scheduled_for,recorded_at,status)
    VALUES ('11111111-2222-4333-8444-555555555555',
      'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
      '2026-11-15 08:00:00+00','2026-11-15 08:02:00+00','taken');
    RAISE EXCEPTION 'Duplicate occurrence accepted';
  EXCEPTION WHEN unique_violation THEN NULL;
  END;
  BEGIN
    INSERT INTO medications(id,user_id,name)
    VALUES ('11111111-2222-4333-8444-666666666666',
      '33333333-3333-4333-8333-333333333333', repeat('x',161));
    RAISE EXCEPTION 'Overlong medication name accepted';
  EXCEPTION WHEN check_violation THEN NULL;
  END;
  BEGIN
    DELETE FROM medications WHERE id='eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee';
    RAISE EXCEPTION 'Medication with dose history deleted';
  EXCEPTION WHEN foreign_key_violation THEN NULL;
  END;
END $$;
ROLLBACK;
