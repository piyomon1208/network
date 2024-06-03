#!/bin/bash

# 모니터링 주기 (초)
INTERVAL=10
THRESHOLD=1000000  # 트래픽 임계치 (바이트)

# 로그 파일 경로
LOG_FILE="/var/log/network_traffic_monitor.log"
INTERFACE="eth0"

# 네트워크 트래픽 체크 함수
check_network_traffic() {
    RX_BYTES=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
    TX_BYTES=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)
    TOTAL_BYTES=$((RX_BYTES + TX_BYTES))
    
    if (( TOTAL_BYTES > THRESHOLD )); then
        echo "Network traffic is above threshold: $TOTAL_BYTES bytes"
        send_alert "Network traffic is above threshold: $TOTAL_BYTES bytes"
    fi
}

# 경고 알림 함수
send_alert() {
    MESSAGE=$1
    echo "$(date): $MESSAGE" | sudo tee -a $LOG_FILE
}

# 메인 루프
while true; do
    check_network_traffic
    sleep $INTERVAL
done
