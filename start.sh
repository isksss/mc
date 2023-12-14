#!/bin/bash
#===== info =====#
# new paper server
#================#

#===== var =====#
PROJECT="paper"
VERSION="1.20.2"
MEMORY="2014M"

CONFIG_JSON=".config.json"
#===============#

#===== init =====#
# load publib manager
. <(curl -fsSL https://raw.githubusercontent.com/isksss/publib/main/sh/manager.sh)

# load some file
load_publib log.sh
load_publib paper.sh
#================#

#===== func =====#
function plugin-download(){
    mkdir -p plugins
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
        log_info "download plugin: $name"
        curl -fsSL -X GET $url -o plugins/$name
    done
}
#================#

COMMAND=$1
case ${COMMAND} in
    "all")
        paper-download ${PROJECT} ${VERSION}
        plugin-download
        paper-run ${MEMORY}
        ;;
    "dl")
        paper-download ${PROJECT} ${VERSION}
        ;;
    "pl")
        plugin-download
        ;;
    "run")
        paper-run ${MEMORY}
        ;;
    "stop")
        paper-stop
        ;;
    *)
        echo "Usage: $0 {dl|run|stop}"
        ;;
esac