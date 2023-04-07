#!/bin/bash

cd ~
git clone https://github.com/aligungr/UERANSIM

sudo apt update -y && sudo apt upgrade -y
sudo apt install -y make
sudo apt install -y gcc
sudo apt install -y g++
sudo apt install -y libsctp-dev lksctp-tools
sudo apt install -y iproute2
sudo snap install cmake --classic
cd UERANSIM
make