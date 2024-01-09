#!/bin/bash
#===== info =====#
# For Ubuntu.
#================#
# .env.sh
ENV_FILE=".env.sh"
CURRENT_DIR=$(cd $(dirname $0); pwd)
#================#

#===== func =====#
function check_rquirement(){
    local app=$1
    if ! type $1 > /dev/null 2>&1; then
        sudo apt install -y $1
    fi
}

#===== init =====#
if [ ! -f $ENV_FILE ]; then
    # create .env.sh
    echo "#===== For your settings =====#" > $ENV_FILE
    echo "export PROJECT=paper" >> $ENV_FILE
    echo "export VERSION=1.20.2" >> $ENV_FILE
    echo "export MEMORY=6G" >> $ENV_FILE
    echo "#===== NOT CHANGE =====#" >> $ENV_FILE
    echo "export server_jar=server.jar" >> $ENV_FILE
    echo "export screen_name=minecraft" >> $ENV_FILE

    #install requirements
    sudo apt update
    check_rquirement curl
    check_rquirement jq
    check_rquirement screen
    check_rquirement openjdk-17-jdk
    check_rquirement fonts-ipafont
    check_rquirement fonts-ipaexfont
    check_rquirement fonts-noto-cjk
    check_rquirement fonts-noto-cjk-extra
    check_rquirement fonts-noto-color-emoji
    check_rquirement cron
    sudo fc-cache -fv

    # echo info
    echo "Please edit .env.sh."
    echo "Run start.sh."

    # change permission
    chmod +x start.sh
    chmod +x restart.sh

else
    # load env
    source $ENV_FILE
    
    # create cron
    crontab -l > /tmp/crontab.tmp
    MY_CRONTAB=${CURRENT_DIR}/crontab.tmp
    # crontabの中身を書き換える
    echo "@reboot '${CURRENT_DIR}/start.sh'" > ${MY_CRONTAB}
    echo "0 6 * * * '${CURRENT_DIR}/restart.sh'" >> ${MY_CRONTAB}
    crontab ${MY_CRONTAB}
fi

