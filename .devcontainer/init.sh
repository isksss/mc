#!/bin/bash

sudo apt update
sudo apt install -y \
    openjdk-17-jdk \
    jq \
    curl \
    screen \
    cron

# システムユーザ
sudo useradd -U -s /sbin/nologin -r minecraft

sudo ln -sf ../.settings/cron/cron_server /etc/cron.d/cron_server
sudo service cron restart