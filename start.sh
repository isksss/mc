#!bin/bash
##### args #####
PAPER_PROJECT="paper"
PAPER_VERSION="1.16.5"
PAPER_BIN="paper.jar"

##### prepare #####
# check exist.
function require(){
    if ! [ -x "`command -v $1`" ]; then
        echo "$1 is not installed."
        sudo apt install -y $2 &>/dev/null
    fi

    echo "$1 is installed."
}

require curl curl
require jq curl
require java openjdk-17-jdk

##### download paper #####
PAPER_URL="https://api.papermc.io/v2/projects/${PAPER_PROJECT}/versions/${PAPER_VERSION}"

build_res=`curl -X GET ${PAPER_URL} -H 'accept: application/json'`

LATEST_BUILD=`echo $build_res | jq ".builds[-1]"`

DOWNLOAD_URL="${PAPER_URL}/builds/${LATEST_BUILD}/downloads/${PAPER_PROJECT}-${PAPER_VERSION}-${LATEST_BUILD}.jar"

curl -X GET ${DOWNLOAD_URL} -H 'accept: application/json' -O ${PAPER_BIN}
