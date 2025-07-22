#!/bin/bash

# System Health Monitor - by Fahad
refresh_rate=3
log_file="anomalies.log"
show_all=true

# Color codes
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

draw_bar() {
    local value=$1
    local length=$((value / 2))
    local color=$2

    printf "["
    for ((i=0; i<length; i++)); do printf "#"; done
    for ((i=length; i<50; i++)); do printf " "; done
    printf "] $color$value%%%s\n" "$NC"
}

log_anomaly() {
    local msg=$1
    echo "$(date +'%F %T') - $msg" >> "$log_file"
}

get_cpu_usage() {
    top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}'
}

get_memory_usage() {
    free | awk '/Mem/ { printf "%.0f", $3/$2 * 100 }'
}

get_disk_usage() {
    df / | awk 'NR==2 {print $5}' | tr -d '%'
}

get_network_stats() {
    RX=$(cat /proc/net/dev | awk '/eth0|wlan0/ {rx+=$2} END {print rx}')
    TX=$(cat /proc/net/dev | awk '/eth0|wlan0/ {tx+=$10} END {print tx}')
    echo "RX: $RX bytes, TX: $TX bytes"
}

check_and_log() {
    [[ $1 -gt 80 ]] && log_anomaly "$2 usage critical at $1%"
}

print_dashboard() {
    clear
    echo "===== 🖥️ System Health Monitor ====="
    echo "Refresh rate: ${refresh_rate}s | Press (r)ate, (f)ilter, (q)uit"
    echo

    cpu=$(get_cpu_usage)
    mem=$(get_memory_usage)
    disk=$(get_disk_usage)

    cpu_color=$GREEN; [[ $cpu -gt 70 ]] && cpu_color=$YELLOW; [[ $cpu -gt 90 ]] && cpu_color=$RED
    mem_color=$GREEN; [[ $mem -gt 70 ]] && mem_color=$YELLOW; [[ $mem -gt 90 ]] && mem_color=$RED
    disk_color=$GREEN; [[ $disk -gt 70 ]] && disk_color=$YELLOW; [[ $disk -gt 90 ]] && disk_color=$RED

    echo -n "CPU Usage   : "; draw_bar $cpu $cpu_color
    echo -n "Memory Usage: "; draw_bar $mem $mem_color
    echo -n "Disk Usage  : "; draw_bar $disk $disk_color

    check_and_log $cpu "CPU"
    check_and_log $mem "Memory"
    check_and_log $disk "Disk"

    if $show_all; then
        echo
        echo -e "Network     : $(get_network_stats)"
        echo -e "Log File    : $log_file"
    fi
}

# Read input without enter
read_input() {
    read -t 0.1 -n 1 key
    case "$key" in
        r)
            echo -n "Enter new refresh rate (seconds): "
            read rate
            [[ $rate =~ ^[0-9]+$ ]] && refresh_rate=$rate
            ;;
        f)
            show_all=!$show_all
            ;;
        q)
            echo "Exiting..."
            exit 0
            ;;
    esac
}

# Main loop
while true; do
    print_dashboard
    read_input
    sleep $refresh_rate
done
