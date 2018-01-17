#!/bin/bash
HERE=$(dirname $(readlink -m $0))
# Install and configure LXD on Travis-CI
debconf-set-selections $HERE/lxd-debconf
echo 'deb http://archive.ubuntu.com/ubuntu trusty-backports main restricted universe multiverse' > /etc/apt/sources.list.d/backports.list
apt-get -qq update;
apt-get -y install -t trusty-backports ca-certificates lxd;
lxd init --auto
usermod -a -G lxd travis
