#!/bin/bash

#===== info =====#
# For Ubuntu.
#===== const =====#
CURRENT_DIR=$(cd $(dirname $0); pwd)
CONFIG_JSON="${CURRENT_DIR}/.config.json"
ENV_FILE="${CURRENT_DIR}/.env.sh"
export LANG=ja_JP.utf8
# load env
source $ENV_FILE
#================#

#===== func =====#
function paper-stop(){
    # stop server
    local SLEEP_TIME=60

    # カウントダウン, 60秒
    for i in $(seq ${SLEEP_TIME} -1 1); do
        local CNT_MESSAGE="${i}秒後にサーバーを再起動します。"
        echo ${CNT_MESSAGE}
        screen -S ${screen_name} -X stuff "say ${CNT_MESSAGE}.\n"
        sleep 1
    done

    local MESSAGE="サーバーを再起動します。1~2分ほどしたら再接続してください。"
    screen -S ${screen_name} -X stuff "kick @a ${MESSAGE}.\n"
    screen -S ${screen_name} -X stuff "stop\n"
    echo "Server stop."
    sleep ${SLEEP_TIME}
    echo "Screen quit."
    screen -S ${screen_name} -X quit
}

#================#

#===== main =====#
# echo
echo "===== restart.sh ====="
echo "===== info ====="
echo "PROJECT: ${PROJECT}"
echo "VERSION: ${VERSION}"
echo "MEMORY: ${MEMORY}"
echo "================"
echo "CURRENT_DIR: ${CURRENT_DIR}"

# stop server
paper-stop
# start server
bash ${CURRENT_DIR}/start.sh
