#!/bin/bash

# Определение корневой директории приложения
APP_DIR="$(cd "$(dirname "$0")" && cd .. && pwd)"

# Пути к файлам
DNS_FILE="$APP_DIR/config/zapret_dns.txt"
SELECT_FASTEST_DNS="$APP_DIR/bin/select_fastest_dns.sh"
PF_RULES_FILE="$APP_DIR/config/pf.conf"

# Проверка существования файлов
if [[ ! -f "$DNS_FILE" ]]; then
  echo "Файл $DNS_FILE не найден."
  exit 1
fi

if [[ ! -f "$SELECT_FASTEST_DNS" ]]; then
  echo "Скрипт $SELECT_FASTEST_DNS не найден."
  exit 1
fi

# Запуск определения самого быстрого DNS-сервера
best_dns=$("$SELECT_FASTEST_DNS")
if [[ $? -ne 0 || -z "$best_dns" ]]; then
  echo "Ошибка при определении самого быстрого DNS-сервера."
  exit 1
fi

echo "Самый быстрый DNS: $best_dns"

# Генерация правил для pf.conf
{
  echo "# Generated pf rules"
  echo "set skip on lo"
  echo "set block-policy drop"
  echo "set fingerprints \"/etc/pf.os\""
  echo "ext_if = \"en0\""
  echo -n "table <zapret_domains> { "
  # Чтение доменов из файла и преобразование в нужный формат
  tr '\n' ',' < "$APP_DIR/config/zapret_domains.txt" | sed 's/,$//'
  echo " }"
  echo "rdr pass on \$ext_if inet proto { tcp, udp } from any to <zapret_domains> port 53 -> $best_dns port 53"
  echo "pass out on \$ext_if route-to (\$ext_if 192.168.1.1) inet from any to <zapret_domains> keep state"
} > "$PF_RULES_FILE"

echo "Правила pf.conf успешно сгенерированы в $PF_RULES_FILE."

echo "Начало генерации pf.conf..."
# Код генерации
if [[ $? -eq 0 ]]; then
  echo "pf.conf успешно сгенерирован."
else
  echo "Ошибка при генерации pf.conf."
  exit 1
fi
