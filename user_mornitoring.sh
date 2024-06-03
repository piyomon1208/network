#!/bin/bash

# 모니터링 주기 (초)
INTERVAL=10

# 로그인 기록 로그 파일 경로
LOGIN_LOG_FILE="/var/log/user_login_monitor.log"

# 명령어 기록 로그 파일 경로
COMMAND_LOG_FILE="/var/log/user_command_monitor.log"

# 사용자 로그인 기록 체크 함수
check_user_logins() {
    # 현재 로그인 기록 가져오기
    current_logins=$(last -n 5)  # 최근 5개의 로그인 기록만 가져옴
    
    # 로그 파일에 기록
    echo "User Login Records (Last 5 logins):" | sudo tee -a $LOGIN_LOG_FILE
    echo "$current_logins" | sudo tee -a $LOGIN_LOG_FILE
    echo "" | sudo tee -a $LOGIN_LOG_FILE
}

# 사용자 명령어 기록 체크 함수
check_user_commands() {
    # 각 사용자별로 .bash_history 파일을 읽어서 명령어 기록
    for user in $(cut -d: -f1 /etc/passwd); do
        home_dir=$(eval echo ~$user)
        history_file="$home_dir/.bash_history"
        
        if [ -f "$history_file" ]; then
            echo "Command history for user: $user" | sudo tee -a $COMMAND_LOG_FILE
            cat "$history_file" | sudo tee -a $COMMAND_LOG_FILE
            echo "" | sudo tee -a $COMMAND_LOG_FILE
        fi
    done
}

# 메인 루프
while true; do
    # 사용자 로그인 기록 체크
    check_user_logins
    
    # 사용자 명령어 기록 체크
    check_user_commands
    
    # 지정된 주기 동안 대기
    sleep $INTERVAL
done
