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

sudo ln -sf /mc/.settings.d/cron/cron_server /etc/cron.d/cron_server
sudo ln -sf /mc/.settings.d/systemd/start_mc_server.service /etc/systemd/start_mc_server.service

sudo service cron restart
sudo systemctl enable start_mc_server.service
sudo systemctl restart auto_shell.service