#!/bin/bash

# Цветовые коды
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Проверка зависимостей
check_dependencies() {
    if ! command -v sensors &> /dev/null; then
        echo -e "${RED}Ошибка: Утилита 'sensors' не установлена. Установите пакет lm-sensors.${NC}"
        exit 1
    fi
}

# Количество ядер CPU
get_cpu_cores() {
    grep -c "^processor" /proc/cpuinfo
}

# Текущая частота CPU (MHz)
get_cpu_freq() {
    local core=$1
    awk -v core="$core" '/^processor/{i++} i==core+1 && /cpu MHz/{printf "%.0f", $4; exit}' /proc/cpuinfo
}

# Температура CPU (°C)
get_cpu_temp() {
    sensors | grep "Core $1" | awk '{print $3}' | sed 's/+//;s/°C//' | cut -d. -f1
}

# Основной цикл мониторинга
main() {
    check_dependencies
    cores=$(get_cpu_cores)

    while true; do
        clear
        
        # Шапка таблицы
        echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║                    МОНИТОРИНГ ПРОЦЕССОРА                  ║${NC}"
        echo -e "${BLUE}╠═════════════╦══════════════╦══════════════════════════════╣${NC}"
        echo -e "${BLUE}║    Ядро     ║   Частота    ║         Температура          ║${NC}"
        echo -e "${BLUE}╠═════════════╬══════════════╬══════════════════════════════╣${NC}"

        # Данные по каждому ядру
        for (( core=0; core<cores; core++ )); do
            freq=$(get_cpu_freq "$core")
            temp=$(get_cpu_temp "$core")
            
            # Обновление таблицы с новыми значениями, выравнивание
            printf "${BLUE}║${NC} %-15s ${BLUE}║${NC} %-12s ${BLUE}║${NC} %-29s ${BLUE}║${NC}\n" \
                   "Ядро $core" \
                   "$freq MHz" \
                   "${temp:-N/A} °C"
        done

        echo -e "${BLUE}╚═════════════╩══════════════╩══════════════════════════════╝${NC}"
        echo -e "\n${YELLOW}Для выхода нажмите Ctrl+C${NC}"
        
        sleep 1
    done
}

main
