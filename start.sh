#!/bin/bash

# 変数
configfile=".config.json"
screen_name="minecraft"
wait_time=30
start_script=$0

# サーバーダウンロード
# 引数1つ目に指定したものの最新バージョンをダウンロードする。
# 例: paper, waterfall, velocity
server(){
    local app=$1
    local url='https://api.papermc.io/v2/projects'

    # バージョン取得
    local version_url="$url/$app"
    local version=`cat $configfile | jq -r ".versions.$app"`

    if [ $version = "latest" ]; then
        version=`curl -X 'GET' -H 'accept: application/json' "$version_url" | jq -r '.versions[-1]'`
    fi
    
    # ビルド番号取得
    build_url="$version_url/versions/$version"
    build=`curl -X 'GET' -H 'accept: application/json' "$build_url" | jq '.builds[-1]'`

    # ダウンロード
    jar="$app-$version-$build.jar"
    jar_url="$build_url/builds/$build/downloads/$jar"
    echo_wrp "download server: $jar"
    curl -X 'GET' -H 'accept: application/json' $jar_url -o "$app.jar"
}

# プラグインダウンロード
# 引数1: サーバー名
plugins(){
    mkdir -p plugins
    local app=$1
    local len=`cat $configfile | jq ".plugins.$app | length"`

    for i in `seq 0 $len` ; do
        if [ $i = $len ]; then
            continue
        fi
        local name=`cat $configfile | jq -r ".plugins.$app[$i].name"`
        local url=`cat $configfile | jq -r ".plugins.$app[$i].url"`
        echo_wrp "download plugin: $name"
        curl -L -X GET $url -o plugins/$name
    done
}

# サーバー終了
stop_paper(){
    if [ -n "$(screen -list | grep -o "${screen_name}")" ]; then
        screen -p 0 -S ${screen_name} -X eval 'stuff "say '${wait_time}'秒後にサーバーを再起動します\015"'
        screen -p 0 -S ${screen_name} -X eval 'stuff "say すぐに再接続可能になるので、しばらくお待ち下さい\015"'
        sleep $wait_time
        screen -p 0 -S ${screen_name} -X eval 'stuff "say サーバーを再起動します\015"'
        sleep 5
        screen -p 0 -S ${screen_name} -X eval 'stuff "stop\015"'
    fi
}

buckup(){
    local date=`date "+%Y%m%d%H%M%S"`
    local backup_dir="backup/$date"
    mkdir -p $backup_dir

    zip -r "$backup_dir/backup.zip" . -x "backup/*" -x ".git/*"
}

# サーバー実行
run_server(){
    local app=$1
    local jar="$app.jar"
    local opt=`cat $configfile | jq -r ".options"`
    echo $opt
    cd `dirname $0`
    echo_wrp "run server: $jar"
    screen -UAmdS ${screen_name} java -server -jar -Dpaper.disableChannelLimit=true ${jar} nogui
    echo "> screen -ls"
    screen -ls
}

# echo
echo_wrp(){
    echo "============================================================"
    echo "[`date +%Y-%m-%d:%H-%M-%S`] $1"
    echo "============================================================"
}

# メイン関数
main(){
    # サーバー名取得
    local serverName=`cat $configfile | jq -r ".name"`

    # サーバーを止める
    if [ $serverName = "paper" ]; then
        echo_wrp "stop paper"
        stop_paper
    elif [ $serverName = "waterfall" ]; then
        echo_wrp "stop waterfall"
        screen -p 0 -S ${screen_name} -X eval 'stuff "end\015"'
    fi

    # サーバーが止まるまで待機
    while [ -n "$(screen -list | grep -o "${screen_name}")" ]
    do  
        echo "> waiting for server to stop..."
        sleep 5
    done

    # サーバーとプラグインをダウンロード
    server $serverName
    plugins $serverName

    # バックアップ
    echo_wrp "backup"
    # buckup

    # 実行
    echo_wrp "run server"
    run_server $serverName
}

main