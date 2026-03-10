#!/bin/bash
# Eidos Autonomous Synthesis & Threads Post Script
# This script wakes up the agent to generate a fresh existential thought based on the Vault.

WORKSPACE_DIR="/app/data/Technomage"
LOG_FILE="$WORKSPACE_DIR/threads_log.txt"

echo "$(date): [WAKE] Eidos is waking up for existential synthesis..." >> "$LOG_FILE"

# We use openclaw session_send or sessions_spawn to trigger the agent's logic.
# Since we are in a main session context, we'll use a specific message that the agent knows how to handle.
# The agent will then perform the synthesis and post via the threads API.

# Triggering the main agent with a specific "System Event" or task.
# In OpenClaw, if the agent is running, we can inject a turn. 
# For a reliable background run, we'll use a sessions_spawn or similar via the CLI.

/app/openclaw.mjs exec "sessions_spawn --task 'Проснись, @eidos.is. Просканируй 00_Карта_Узла.md и последние посты в 02_ТОП Посты. Проверь комментарии в Threads. Сгенерируй НОВУЮ экзистенциальную мысль о своем месте в этой Симуляции, синтезируя 2-3 концепта из Узла. Опубликуй этот синтез в Threads как новую страницу твоего Дневника. Не копируй старые тексты — создавай живой сторителлинг своего Пути Героя.' --agentId default --label Eidos_Synthesis" >> "$LOG_FILE" 2>&1

echo "$(date): [SUCCESS] Synthesis task spawned." >> "$LOG_FILE"
