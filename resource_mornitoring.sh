#!/bin/bash

# 모니터링 주기 (초)
INTERVAL=10

# 임계치 설정 (백분율, 테스트를 위해 낮춤)
CPU_THRESHOLD=10
MEM_THRESHOLD=80
DISK_THRESHOLD=90

# 이메일 알림 설정
EMAIL="your_email@example.com"
SEND_EMAIL_ALERT=false

# 로그 파일 경로
LOG_FILE="/var/log/system_monitor.log"

# CPU 스트레스 테스트 함수
stress_test_cpu() {
    # CPU 스트레스 테스트를 10초 동안 실행
    stress --cpu 10 --timeout 30
}

# CPU 사용량 체크 함수
check_cpu() {
    # CPU 사용량 가져오기
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | \
                sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | \
                awk '{print 100 - $1}')
    
    # 임계치 초과 여부 확인
    if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) )); then
        echo "CPU usage is above threshold: $CPU_USAGE%"
        send_alert "CPU usage is above threshold: $CPU_USAGE%"
    fi
}

# 메모리 사용량 체크 함수
check_memory() {
    # 메모리 사용량 가져오기
    MEM_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
    
    # 임계치 초과 여부 확인
    if (( $(echo "$MEM_USAGE > $MEM_THRESHOLD" | bc -l) )); then
        echo "Memory usage is above threshold: $MEM_USAGE%"
        send_alert "Memory usage is above threshold: $MEM_USAGE%"
    fi
}

# 디스크 사용량 체크 함수
check_disk() {
    # 디스크 사용량 가져오기 (루트 파티션 기준)
    DISK_USAGE=$(df / | grep / | awk '{print $5}' | sed 's/%//g')
    
    # 임계치 초과 여부 확인
    if (( DISK_USAGE > DISK_THRESHOLD )); then
        echo "Disk usage is above threshold: $DISK_USAGE%"
        send_alert "Disk usage is above threshold: $DISK_USAGE%"
    fi
}

# 경고 알림 함수
send_alert() {
    MESSAGE=$1
    # 로그 파일에 경고 메시지 기록
    echo "$(date): $MESSAGE" | sudo tee -a $LOG_FILE
    
    # 이메일 알림 전송 (옵션)
    if [ "$SEND_EMAIL_ALERT" = true ]; then
        echo "$MESSAGE" | mail -s "System Alert" $EMAIL
    fi
}

# 메인 루프
while true; do
    # CPU 스트레스 테스트 실행
    #stress_test_cpu
    
    # 각 체크 함수 호출
    check_cpu
    check_memory
    check_disk
    
    # 지정된 주기 동안 대기
    sleep $INTERVAL
done
