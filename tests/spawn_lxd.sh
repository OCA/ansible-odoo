#!/bin/bash
# Install and configure LXD
sudo add-apt-repository -y ppa:ubuntu-lxc/lxd-stable;
sudo apt-get -qq update;
sudo apt-get -y install lxd;
sudo lxd init --auto
sudo usermod -a -G lxd travis
sudo lxc network create testbr0
sudo lxc network attach-profile testbr0 default eth0
sudo lxc network show testbr0
# Spawn a LXD container
sudo lxc init ${IMAGE} $1
sudo lxc config set $1 raw.lxc "lxc.aa_allow_incomplete=1"
if [[ "$IMAGE" == 'images:debian/jessie' ]]; then sudo ./tests/lxd_fix_debian_jessie.sh $1; fi
sudo lxc start $1
sudo lxc list
sudo sleep 4
sudo lxc list
# Configure the container
sudo lxc exec $1 -- sh -c "apt-get update -qq"
sudo lxc exec $1 -- sh -c "apt-get install -qq python-apt python-pip python-dev lsb-release"
sudo lxc exec $1 -- sh -c "pip install pip --upgrade"
sudo lxc exec $1 -- sh -c "pip install \"ansible>=$ANSIBLE_VERSION\""
sudo lxc exec $1 -- sh -c "pip install pyopenssl>=0.16.2 --upgrade"
sudo lxc exec $1 -- sh -c "apt-get install -y postgresql postgresql-contrib"
sudo lxc config set $1 environment.ODOO_VERSION $ODOO_VERSION
sudo lxc config set $1 environment.ODOO_INSTALL_TYPE $ODOO_INSTALL_TYPE
