#!/bin/bash

# MONGO
sudo apt update -y && sudo apt upgrade -y
sudo apt install wget gnupg
wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -
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
sudo apt install -y curl
curl -fsSL https://deb.nodesource.com/setup_19.x | sudo -E bash -
sudo apt-get update
sudo apt install -y nodejs
cd ~/open5gs/webui
npm ci --no-optional
cd ~/open5gs

# TUN
sudo ip tuntap add name ogstun mode tun && \
sudo ip addr add 10.45.0.1/16 dev ogstun && \
sudo ip addr add 2001:230:cafe::1/48 dev ogstun && \
sudo ip link set ogstun up

# ROUTING
### Enable IPv4/IPv6 Forwarding
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -w net.ipv6.conf.all.forwarding=1

### Add NAT Rule
sudo iptables -t nat -A POSTROUTING -s 10.45.0.0/16 ! -o ogstun -j MASQUERADE
sudo ip6tables -t nat -A POSTROUTING -s 2001:db8:cafe::/48 ! -o ogstun -j MASQUERADE

sudo ufw disable
### Ensure that the packets in the `INPUT` chain to the `ogstun` interface are accepted
sudo iptables -I INPUT -i ogstun -j ACCEPT

### Prevent UE's from connecting to the host on which UPF is running
sudo iptables -I INPUT -s 10.45.0.0/16 -j DROP
sudo ip6tables -I INPUT -s 2001:db8:cafe::/48 -j DROP

### If your core network runs over multiple hosts, you probably want to block
### UE originating traffic from accessing other network functions.
sudo iptables -I FORWARD -s 10.45.0.0/16 -d 127.0.0.0/24 -j DROP