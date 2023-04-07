#!/bin/bash

# MONGO
sudo apt update -y && sudo apt upgrade -y
sudo apt install wget gnupg
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list
sudo apt update -y
sudo apt install -y mongodb-org
sudo systemctl start mongod
sudo systemctl enable mongod

# INSTALL v2.6.1
cd ~
git clone --branch v2.6.1 https://github.com/open5gs/open5gs
cd open5gs

sudo apt install -y python3-pip python3-setuptools python3-wheel ninja-build build-essential flex bison git cmake libsctp-dev libgnutls28-dev libgcrypt-dev libssl-dev libidn11-dev libmongoc-dev libbson-dev libyaml-dev libnghttp2-dev libmicrohttpd-dev libcurl4-gnutls-dev libnghttp2-dev libtins-dev libtalloc-dev meson
meson build --prefix=`pwd`/install
ninja -C build
cd ~/open5gs/build
ninja install

# WEBUI
sudo apt install curl
curl -fsSL https://deb.nodesource.com/setup_19.x | sudo -E bash -
sudo apt install nodejs
cd ~/open5gs/webui
npm ci --no-optional
cd open5gs

# TUN
sudo ip tuntap add name ogstun mode tun
sudo ip addr add 10.45.0.1/16 dev ogstun
sudo ip addr add 2001:230:cafe::1/48 dev ogstun
sudo ip link set ogstun up
