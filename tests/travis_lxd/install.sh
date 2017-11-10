#!/bin/bash
# Install and configure LXD on Travis-CI
add-apt-repository -y ppa:ubuntu-lxc/lxd-stable;
apt-get -qq update;
apt-get -y install lxd;
lxd init --auto
usermod -a -G lxd travis
lxc network create testbr0
lxc network attach-profile testbr0 default eth0
lxc network show testbr0
