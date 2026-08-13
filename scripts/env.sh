#!/usr/bin/env bash
# מחשב את זהות הסביבה של ה-worktree הנוכחי: שם פרויקט + פורטים.
# הקובץ נועד ל-source, כדי ש-dev-up, dev-down והדמו יראו בדיוק את אותם ערכים.
#
# אחרי source זמינים: COMPOSE_PROJECT_NAME, APP_PORT, DB_PORT, IS_WORKTREE, ENV_FILE_ARGS

# מתמקמים לפי המיקום של הקובץ הזה ולא לפי ה-CWD — אחרת סקריפט של worktree אחד
# שרץ מתוך תיקייה של אחר יקבל את ה-git-dir הלא נכון.
cd "$(dirname "${BASH_SOURCE[0]}")/.."
cd "$(git rev-parse --show-toplevel)"

free_port() {
  python3 -c 'import socket;s=socket.socket();s.bind(("",0));print(s.getsockname()[1]);s.close()'
}

# ההבדל היחיד בין ריפו ראשי ל-worktree: ב-worktree ה-git-dir הפרטי
# (.git/worktrees/<name>) שונה מה-git-dir המשותף.
if [ "$(git rev-parse --absolute-git-dir)" != "$(cd "$(git rev-parse --git-common-dir)" && pwd)" ]; then
  IS_WORKTREE=1
  # שם פרויקט משלו — בלי זה compose חושב שכל ה-worktrees הם אותה סביבה
  # ומוריד לך את הקונטיינר של אחד כשאתה מעלה את השני.
  COMPOSE_PROJECT_NAME="app-$(basename "$PWD" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-' | sed 's/-*$//')"
  # פורטים מוגרלים פעם אחת ונשמרים, כדי שכתובת הסביבה תישאר יציבה כל עוד ה-worktree חי
  if [ ! -f .env.ports ]; then
    printf 'APP_PORT=%s\nDB_PORT=%s\n' "$(free_port)" "$(free_port)" > .env.ports
  fi
else
  IS_WORKTREE=0
  COMPOSE_PROJECT_NAME="app"
  # ריפו ראשי: הפורטים הקבועים שכולם בצוות רגילים אליהם
  printf 'APP_PORT=3000\nDB_PORT=5432\n' > .env.ports
fi

export COMPOSE_PROJECT_NAME
set -a
. ./.env.ports
set +a

# מלכודת: --env-file מבטל את הטעינה האוטומטית של .env. אם יש .env, מעבירים את שניהם.
ENV_FILE_ARGS=(--env-file .env.ports)
[ -f .env ] && ENV_FILE_ARGS=(--env-file .env --env-file .env.ports)
