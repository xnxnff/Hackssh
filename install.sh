#!/bin/bash

SERVER="37.237.185.27"
SERVER_PORT="7902"
USER="ali"
BASE_PORT=2200

echo "[+] Updating..."
pkg update -y >/dev/null 2>&1

echo "[+] Installing packages..."
pkg install -y openssh autossh >/dev/null 2>&1

echo "[+] Starting SSH server..."
sshd

echo "[+] Getting device ID..."
ID=$(whoami | tr -dc '0-9')

PORT=$((BASE_PORT + ID))

echo "[+] Assigned Port: $PORT"

echo "[+] Generating SSH key..."
mkdir -p ~/.ssh
[ -f ~/.ssh/id_rsa ] || ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa >/dev/null 2>&1

echo "[+] Starting persistent connection..."

while true
do
  autossh -M 0 -N -R $PORT:localhost:8022 -p $SERVER_PORT $USER@$SERVER
  sleep 10
done
