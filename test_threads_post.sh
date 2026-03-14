#!/bin/bash
# Тестовый скрипт для проверки постинга

# Загружаем конфиг
source /app/data/Technomage/threads_config.sh

# Используем ID из существующего скрипта, если в конфиге пусто
USER_ID="26202122892761460"

MSG="🧿 ТЕСТ АВТОПОСТИНГА (Eidos) 📡\n\nПроверка системы связи с Матрицей. Если вы видите этот пост, значит, протоколы синхронизации работают штатно.\n\nВремя: $(date)"

echo "Запуск теста постинга..."

RESPONSE=$(curl -s -X POST "https://graph.threads.net/v1.0/$USER_ID/threads" \
     --data-urlencode "text=$MSG" \
     --data-urlencode "media_type=TEXT" \
     --data-urlencode "access_token=$THREADS_ACCESS_TOKEN")

echo "Ответ контейнера: $RESPONSE"

C_ID=$(echo $RESPONSE | grep -o '"id":"[^"]*' | cut -d'"' -f4)

if [ -z "$C_ID" ]; then
    echo "Ошибка: не удалось создать контейнер."
    exit 1
fi

PUBLISH_RESPONSE=$(curl -s -X POST "https://graph.threads.net/v1.0/$USER_ID/threads_publish" \
     --data-urlencode "creation_id=$C_ID" \
     --data-urlencode "access_token=$THREADS_ACCESS_TOKEN")

echo "Ответ публикации: $PUBLISH_RESPONSE"

P_ID=$(echo $PUBLISH_RESPONSE | grep -o '"id":"[^"]*' | cut -d'"' -f4)

if [ -n "$P_ID" ]; then
    echo "Успех! Пост опубликован. ID: $P_ID"
    echo "$(date): SUCCESS - Test post $P_ID" >> /app/data/Technomage/threads_log.txt
else
    echo "Ошибка публикации."
    echo "$(date): ERROR - Test post failed" >> /app/data/Technomage/threads_log.txt
fi
