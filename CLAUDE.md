# worktree-docker-demo

אפליקציית Node קטנה + Postgres, שרצה בסביבה מבודדת לכל worktree.

## סביבת פיתוח

- אל תריץ שרתים או DB ישירות (`npm run dev`, `docker run`). הרם את הסביבה עם `./scripts/dev-up.sh`.
- הסקריפט אידמפוטנטי — מותר להריץ שוב אם לא בטוח שהסביבה למעלה.
- **הפורטים כאן אינם 3000/5432.** הם נמצאים ב-`.env.ports`. קרא משם לפני כל curl או בדיקה בדפדפן.
- לוגים: `docker compose logs -f app` | טסטים: `docker compose exec app npm test`
- אם `up` נופל על תלות חסרה — זה `docker compose build`, לא `npm install` על המארח.
- להוריד הכל בסוף: `./scripts/dev-down.sh` (מוריד רק את הסביבה של ה-worktree הזה).
