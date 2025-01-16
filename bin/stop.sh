#!/bin/bash

PF_ANCHOR_NAME="myapp"

# Удаление всех правил из якоря
sudo pfctl -a "$PF_ANCHOR_NAME" -F rules
if [[ $? -ne 0 ]]; then
  echo "Ошибка очистки правил из якоря $PF_ANCHOR_NAME."
  exit 1
fi

echo "Правила PF из якоря $PF_ANCHOR_NAME успешно удалены."
