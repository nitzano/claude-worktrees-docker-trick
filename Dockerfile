# ה-image מכיל *רק* את התלויות. הקוד נכנס פנימה כ-bind mount בזמן ריצה.
# לכן worktree חדש הוא לא build חדש — הוא אותו image עם תיקייה אחרת ממופה.
FROM node:22-alpine

WORKDIR /app

# רק המניפסטים — כדי שהשכבה הזאת תישאר ב-cache כל עוד התלויות לא השתנו
COPY package.json package-lock.json* ./
RUN npm install

# עותק ראשוני של הקוד, כדי שה-image ירוץ גם בלי mount (למשל ב-CI).
# ב-dev ה-bind mount דורס אותו ממילא.
COPY . .

EXPOSE 3000
CMD ["npm", "run", "dev"]
