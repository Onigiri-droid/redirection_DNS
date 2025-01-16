#!/bin/bash

# Перезапуск службы DNSCrypt
sudo brew services restart dnscrypt-proxy

# Список DNS для тестирования
dns_servers=(
  "127.0.0.1"
  "8.8.8.8"          # Google Public DNS
  "9.9.9.9"          # Quad9 DNS
  "77.88.8.8"        # Yandex.DNS
  "208.67.222.222"   # OpenDNS
  "94.140.14.14"     # AdGuard DNS
  "1.0.0.1"          # Cloudflare DNS
  "8.8.4.4"          # Google Public DNS (Secondary)
  "149.112.112.112"  # Quad9 DNS (Secondary)
  "185.228.168.168"  # CleanBrowsing DNS (Security)
  "185.228.169.168"  # CleanBrowsing DNS (Family)
  "209.244.0.3"      # Level3 DNS
  "64.6.64.6"        # Neustar DNS
  "64.6.65.6"        # Neustar DNS (Secondary)
  "156.154.70.1"     # Neustar DNS (Primary)
  "156.154.71.1"     # Neustar DNS (Secondary)
  # "1.1.1.1"          # Cloudflare DNS (Primary)
  "208.67.220.220"   # OpenDNS FamilyShield
  "216.146.35.35"    # DNS.Watch
  "216.146.36.36"    # DNS.Watch (Secondary)
  # "45.33.97.5"       # DNS filter (Adult Content)
  "9.9.9.10"         # Quad9 DNS (DNS over HTTPS)
)

# Функция тестирования DNS
test_dns() {
  local server=$1
  local result
  result=$(dig @$server youtube.com +noall +stats | grep "Query time" | awk '{print $4}')
  echo "$result"
}

# Тестируем все DNS и сохраняем результаты
echo "Тестирование DNS..."
results=()
for dns in "${dns_servers[@]}"; do
  latency=$(test_dns "$dns")
  
  # Если время отклика найдено
  if [[ "$latency" =~ ^[0-9]+$ ]]; then
    echo "DNS: $dns - $latency ms"
    results+=("$dns,$latency")
  else
    echo "DNS $dns не дал корректного ответа или не дал ответа вообще."
  fi
done

# Поиск DNS с минимальным временем отклика
best_dns=""
best_latency=999999
for entry in "${results[@]}"; do
  dns=$(echo $entry | cut -d',' -f1)
  latency=$(echo $entry | cut -d',' -f2)

  # Сравниваем, если найдено корректное время отклика
  if [[ "$latency" =~ ^[0-9]+$ ]] && [ "$latency" -lt "$best_latency" ]; then
    best_latency=$latency
    best_dns=$dns
  fi
done

# Если найден лучший DNS
if [ -z "$best_dns" ]; then
  echo "Не удалось найти лучший DNS."
else
  echo "Лучший DNS: $best_dns"
  echo "Устанавливаем лучший DNS ($best_dns)..."
  networksetup -setdnsservers Wi-Fi "$best_dns"
fi

# Проверка результата
echo "Установленные DNS:"
networksetup -getdnsservers Wi-Fi

echo "GoodbyeDPI для macOS запущен. DNS направлен через dnscrypt-proxy."


# sudo brew services stop dnscrypt-proxy - остановка сервера
# networksetup -setdnsservers Wi-Fi empty - сброс днс к стандартным

# dig youtube.com/dig example.com - для проверки
# /Users/kirillov/Desktop/goodbyedpi_mac.sh - для запуска

#simple запуск
# #!/bin/bash

# # Перезапуск службы DNSCrypt
# sudo brew services restart dnscrypt-proxy

# # Установка системного DNS
# networksetup -setdnsservers Wi-Fi 127.0.0.1

# echo "GoodbyeDPI для macOS запущен. DNS направлен через dnscrypt-proxy."
