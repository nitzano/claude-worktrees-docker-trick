# עשר סביבות פיתוח במקביל — דמו

ריפו מינימלי (Node + Postgres) שמדגים את מה שהפוסט מתאר: כל git worktree מקבל
סביבת Docker משלו, עם פורטים פנויים ו-DB נפרד, בלי build מחדש ובלי התנגשויות.

## הרצה מהירה

```bash
cp .env.example .env
./scripts/demo.sh 3     # יוצר 3 worktrees, מרים לכל אחד סביבה, מנקה בסוף
```

`KEEP=1 ./scripts/demo.sh` משאיר את ה-worktrees כדי לשחק איתם ידנית.

## מה יש כאן

| קובץ | תפקיד |
| --- | --- |
| [docker-compose.yml](docker-compose.yml) | פורטים כמשתנים עם ברירת מחדל; הקוד נכנס כ-bind mount |
| [Dockerfile](Dockerfile) | תלויות בלבד — נבנה פעם אחת |
| [scripts/env.sh](scripts/env.sh) | הליבה: זיהוי worktree, הגרלת פורטים, `COMPOSE_PROJECT_NAME` |
| [scripts/dev-up.sh](scripts/dev-up.sh) | הרמה אידמפוטנטית + סידינג מדאמפ |
| [scripts/dev-down.sh](scripts/dev-down.sh) | הורדה של הסביבה הזאת בלבד |
| [scripts/demo.sh](scripts/demo.sh) | ההדגמה מקצה לקצה |
| [CLAUDE.md](CLAUDE.md) | החיווט לקלוד — מגיע לכל worktree דרך גיט |
| [.claude/settings.json](.claude/settings.json) | hook של `SessionStart` שמרים את הסביבה לבד |
| [.worktreeinclude](.worktreeinclude) | קבצים שאינם בגיט ובכל זאת צריכים להגיע ל-worktree |

## שלוש נקודות שקל לפספס

1. **`COMPOSE_PROJECT_NAME` שונה לכל worktree.** בלעדיו compose מתייחס לכולם כאותה
   סביבה ומוריד לך קונטיינר אחד כשאתה מעלה את השני.
2. **רק הפורטים החיצוניים משתנים.** בתוך הרשת של compose האפליקציה עדיין מדברת עם
   `db:5432`, אז אין קונפיגורציה פנימית שצריכה לדעת באיזו סביבה היא רצה.
3. **`--env-file` מבטל את הטעינה האוטומטית של `.env`.** לכן
   [scripts/env.sh](scripts/env.sh) מעביר את שניהם כשיש `.env`.
