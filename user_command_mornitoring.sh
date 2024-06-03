#!/bin/bash

# 로그 파일 경로
LOG_FILE="/var/log/user_login_monitor.log"

# 사용자 로그인 기록
echo "User Login: $(whoami) at $(date)" | sudo tee -a $LOG_FILE

# 명령어 기록 함수
log_command() {
    echo "User Command: $(whoami) executed: $BASH_COMMAND at $(date)" | sudo tee -a $LOG_FILE
}

# trap DEBUG를 통해 모든 명령어 실행 전 log_command 함수를 호출
trap 'log_command' DEBUG
