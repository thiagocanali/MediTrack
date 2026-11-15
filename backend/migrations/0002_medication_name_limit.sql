-- Prevent oversized medication names bypassing Flutter's 160-character input limit.
BEGIN;
ALTER TABLE medications ADD CONSTRAINT medications_name_length
  CHECK (char_length(name) BETWEEN 1 AND 160);
COMMIT;
