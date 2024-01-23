#!/bin/bash
set -e

cp ./velocity.service /etc/systemd/system/velocity.service
systemctl daemon-reload
systemctl enable velocity.service
systemctl start velocity.service