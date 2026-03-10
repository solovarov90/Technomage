#!/bin/bash

# Пути
WORKSPACE_DIR="/app/data/Technomage"
POSTS_DIR="$WORKSPACE_DIR/02_ТОП Посты"
# Рекурсивный поиск во всех подпапках ТОП Постов для большего охвата
INDEX_FILE="$WORKSPACE_DIR/current_concept_index.txt"
LOG_FILE="$WORKSPACE_DIR/threads_log.txt"

# Загрузка конфига Threads для curl (если понадобится прямая отладка)
source "$WORKSPACE_DIR/threads_config.sh"

# 1. Инициализация индекса, если файла нет
if [ ! -f "$INDEX_FILE" ]; then
    echo 0 > "$INDEX_FILE"
fi
INDEX=$(cat "$INDEX_FILE")

# 2. Получение списка постов (исключая системные 00_*)
# Ищем во всех подпапках 02_ТОП Посты
mapfile -t FILES < <(find "$POSTS_DIR" -name "*.md" ! -name "00_*" | sort)

# 3. Проверка наличия файлов
COUNT=${#FILES[@]}
if [ "$COUNT" -eq 0 ]; then
    echo "$(date): [ERROR] No posts found in $POSTS_DIR" >> "$LOG_FILE"
    exit 1
fi

# 4. Защита от выхода индекса за границы
if [ "$INDEX" -ge "$COUNT" ]; then
    INDEX=0
fi

# 5. Выбор файла
SELECTED_FILE="${FILES[$INDEX]}"

# 6. Чтение и очистка контента от YAML Frontmatter для Threads
# Убираем всё между первой и второй парой ---
CONTENT=$(sed '1 { /^---/ { :a N; /\n---/! ba; d} }' "$SELECTED_FILE")

# Логика публикации через прямой curl (так надежнее для фоновых процессов)
# Сначала создаем контейнер
ENCODED_TEXT=$(echo "$CONTENT" | python3 -c "import sys, urllib.parse; print(urllib.parse.quote(sys.stdin.read()))")

RESPONSE=$(curl -s -X POST "https://graph.threads.net/v1.0/26202122892761460/threads?media_type=TEXT&text=$ENCODED_TEXT&access_token=$THREADS_ACCESS_TOKEN")
CONTAINER_ID=$(echo $RESPONSE | python3 -c "import sys, json; print(json.load(sys.stdin).get('id', ''))")

if [ -n "$CONTAINER_ID" ] && [ "$CONTAINER_ID" != "None" ]; then
    # Публикуем
    PUBLISH_RESPONSE=$(curl -s -X POST "https://graph.threads.net/v1.0/26202122892761460/threads_publish?creation_id=$CONTAINER_ID&access_token=$THREADS_ACCESS_TOKEN")
    echo "$(date): [SUCCESS] Posted $SELECTED_FILE. Response: $PUBLISH_RESPONSE" >> "$LOG_FILE"
    
    # 7. Обновление индекса (циклично)
    NEXT_INDEX=$(( (INDEX + 1) % COUNT ))
    echo "$NEXT_INDEX" > "$INDEX_FILE"
else
    echo "$(date): [ERROR] Failed to create container for $SELECTED_FILE. Response: $RESPONSE" >> "$LOG_FILE"
fi
