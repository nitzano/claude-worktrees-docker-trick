-- דאמפ סידינג — רץ בסוף כל dev-up. חייב להיות אידמפוטנטי.
CREATE TABLE IF NOT EXISTS notes (
  id    serial PRIMARY KEY,
  title text NOT NULL UNIQUE
);

INSERT INTO notes (title) VALUES
  ('סביבה ראשונה'),
  ('סביבה שנייה')
ON CONFLICT (title) DO NOTHING;
