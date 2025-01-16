#!/bin/bash

APP_DIR="$(cd "$(dirname "$0")" && cd .. && pwd)"
PF_ANCHOR_NAME="myapp"
PF_CONF_FILE="$APP_DIR/config/pf.conf"
GENERATE_SCRIPT="$APP_DIR/bin/generate_pf_rules.sh"

# Генерация файла конфигурации PF
if [[ -x "$GENERATE_SCRIPT" ]]; then
  "$GENERATE_SCRIPT"
else
  echo "Скрипт $GENERATE_SCRIPT не найден или не является исполняемым."
  exit 1
fi

# Проверка существования файла с правилами
if [[ ! -f "$PF_CONF_FILE" ]]; then
  echo "Файл $PF_CONF_FILE не найден. Убедитесь, что генерация правил завершена успешно."
  exit 1
fi

# Загрузка правил в якорь
sudo pfctl -a "$PF_ANCHOR_NAME" -f "$PF_CONF_FILE"
if [[ $? -ne 0 ]]; then
  echo "Ошибка загрузки правил в якорь $PF_ANCHOR_NAME."
  exit 1
fi

# Включение PF, если он не активен
if ! sudo pfctl -s info | grep -q "Status: Enabled"; then
  sudo pfctl -e
  if [[ $? -ne 0 ]]; then
    echo "Ошибка включения PF."
    exit 1
  fi
fi

echo "Правила PF успешно загружены в якорь $PF_ANCHOR_NAME и PF активирован."
