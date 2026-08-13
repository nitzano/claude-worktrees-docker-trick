-- Seed dump — runs at the end of every dev-up, so it has to be idempotent.
CREATE TABLE IF NOT EXISTS notes (
  id    serial PRIMARY KEY,
  title text NOT NULL UNIQUE
);

INSERT INTO notes (title) VALUES
  ('first note'),
  ('second note')
ON CONFLICT (title) DO NOTHING;
