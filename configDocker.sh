#!/bin/bash

echo "[4/13] Installing Docker and other needed 3rd parties"

sudo apt-get -y update

sudo apt-get -y install ca-certificates curl gnupg lsb-release unzip jq

sudo apt-get -y install docker-ce docker-ce-cli containerd.io

echo -e "[4/13] Done.\n\n"

 

echo "[5/13] Configure Docker"

sudo usermod -a -G docker $USER

sudo systemctl enable docker.service

sudo systemctl start docker.service

sudo chmod 666 /var/run/docker.sock

echo -e "[5/13] Done.\n\n"