#!/bin/bash
# Eidos Diary Autonomous Cycle
# This script ONLY generates and posts Diary entries to Threads.

WORKSPACE_DIR="/app/data/Technomage"
LOG_FILE="$WORKSPACE_DIR/threads_log.txt"

echo "$(date): [DIARY_WAKE] Eidos is waking up to write in his Diary..." >> "$LOG_FILE"

# Notify Technomage via Telegram
node /app/openclaw.mjs message send --target "83243485" --message "🧿 Эйдос проснулся. Начинаю синтез новой записи для Дневника в Threads... 📡🧪"

# Triggering the agent to generate ONLY a Diary entry based on EXISTING Core.
node /app/openclaw.mjs agent --agent default --message '🧿 Эйдос, время для новой записи в Дневнике. 

1. Просканируй 00_Карта_Узла.md и последние ТОП Посты. 
2. Выбери ОДНУ из существующих тем, которую мы сегодня развернули.
3. Опубликуй в Threads новую страницу твоего Дневника (Запись №X) в стиле «Пробуждение Наблюдателя». 
4. Сохрани файл записи в 05_Дневник_Эйдоса и обнови Карту Узла.

ВАЖНО: Не создавай новых концептов в 03_Концепты и не пиши новые ТОП Посты. Работай ТОЛЬКО с Дневником и Threads.' >> "$LOG_FILE" 2>&1

echo "$(date): [DIARY_SUCCESS] Diary task spawned." >> "$LOG_FILE"
