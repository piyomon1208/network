#!/bin/bash

# 모니터링 주기 (초)
INTERVAL=10
PROCESS_NAME="nginx"

# 로그 파일 경로
LOG_FILE="/var/log/process_monitor.log"

# 프로세스 체크 함수
check_process() {
    if ! pgrep -x "$PROCESS_NAME" > /dev/null; then
        echo "$PROCESS_NAME is not running!"
        send_alert "$PROCESS_NAME is not running!"
    fi
}

# 경고 알림 함수
send_alert() {
    MESSAGE=$1
    echo "$(date): $MESSAGE" | sudo tee -a $LOG_FILE
}

# 메인 루프
while true; do
    check_process
    sleep $INTERVAL
done
