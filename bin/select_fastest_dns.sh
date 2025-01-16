#!/bin/bash

# Файл с DNS-серверами
DNS_FILE="$(dirname "$0")/../config/zapret_dns.txt"

# Проверка существования файла
if [[ ! -f "$DNS_FILE" ]]; then
  echo "Файл $DNS_FILE не найден."
  exit 1
fi

# Функция для тестирования DNS
test_dns() {
  local server=$1
  local result
  result=$(dig @$server youtube.com +noall +stats | grep "Query time" | awk '{print $4}')
  echo "$result"
}

# Инициализация переменных
best_dns=""
best_latency=999999

# Чтение и тестирование DNS-серверов
while IFS= read -r dns; do
  [[ -z "$dns" || "$dns" =~ ^# ]] && continue
  latency=$(test_dns "$dns")
  if [[ "$latency" =~ ^[0-9]+$ && "$latency" -lt "$best_latency" ]]; then
    best_latency=$latency
    best_dns=$dns
  fi
done < "$DNS_FILE"

# Вывод самого быстрого DNS
if [[ -n "$best_dns" ]]; then
  echo "$best_dns"
else
  exit 1
fi
