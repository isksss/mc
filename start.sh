#!/bin/bash
#===== info =====#
# For Ubuntu.
#================#

#===== const =====#
CURRENT_DIR=$(cd $(dirname $0); pwd)
CONFIG_JSON="${CURRENT_DIR}/.config.json"
ENV_FILE="${CURRENT_DIR}/.env.sh"
export LANG=ja_JP.utf8
#=================#

#===== func =====#
function paper-download(){
    local project=$1 #ex) paper, velocity
    local version=$2 #ex) 1.16.5

    local url="https://api.papermc.io/v2/projects/${PROJECT}/versions/${VERSION}"

    local response=$(curl -X GET -H 'accept: application/json' -fsSL ${url})
    local build=`echo ${response} | jq -r '.builds[-1]'`
    local jar="${PROJECT}-${VERSION}-${build}.jar"
    local jar_url="${url}/builds/${build}/downloads/${jar}"
    # download jar
    echo "download server: ${jar}"
    curl -X GET -H 'accept: application/json' -fsSL ${jar_url} -o ${CURRENT_DIR}/${server_jar}
}

function plugin-download(){
    local plugins_dir="${CURRENT_DIR}/plugins"
    mkdir -p ${plugins_dir}
    local len=`cat $CONFIG_JSON | jq ".plugins.$PROJECT | length"`
    if [ $len = 0 ]; then
        return
    fi
    for i in `seq 0 $len` ; do
        if [ $i = $len ]; then
            continue
        fi
        local name=`cat $CONFIG_JSON | jq -r ".plugins.$PROJECT [$i].name"`
        local url=`cat $CONFIG_JSON | jq -r ".plugins.$PROJECT [$i].url"`
        echo "download plugin: $name"
        curl -fsSL -X GET $url -o ${plugins_dir}/$name
    done
}

function paper-run(){
    # if screen is not exist, create screen.
    if screen -list | grep -q "${screen_name}"; then
        screen -S ${screen_name}  -X quit
    fi
    screen -AdmSU ${screen_name}

    # run server
    echo "run server."
    screen -S ${screen_name} -X stuff "java -Xms${MEMORY} -Xmx${MEMORY} -jar ${CURRENT_DIR}/${server_jar} nogui\n"
}
#================#

#===== main =====#
if [ ! -e $ENV_FILE ];then
    echo "${ENV_FILE} is not found."
    echo "Run init.sh."
    exit 1
fi
# load env
. $ENV_FILE

# download
paper-download
plugin-download

paper-run