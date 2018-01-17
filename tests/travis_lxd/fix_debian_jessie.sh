#!/bin/bash
# This script fix the Debian Jessie container by replacing systemd by SysV
#
CT_DIR="/var/lib/lxd/containers/$1"
ROOTFS="$CT_DIR/rootfs"
UID_GID=$(ls -n $CT_DIR | grep rootfs | cut -d ' ' -f "3-4")
CT_UID=$(echo $UID_GID | cut -d ' ' -f1)
CT_GID=$(echo $UID_GID | cut -d ' ' -f2)
CT_UID_GID="$CT_UID:$CT_GID"
BRIDGE_IP=$(/sbin/ifconfig lxdbr0 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}')
# Configure the network of the container
echo -e "nameserver $BRIDGE_IP\nsearch lxd" > $ROOTFS/etc/resolv.conf
cat $ROOTFS/etc/resolv.conf
chroot --userspec=$CT_UID_GID $ROOTFS apt-get update
chroot --userspec=$CT_UID_GID $ROOTFS apt-get install -y sysvinit-core -d
chroot $ROOTFS apt-get install -y sysvinit-core
chroot --userspec=$CT_UID_GID $ROOTFS apt-get update
chown $CT_UID_GID $ROOTFS/var/log/apt/term.log
chown $CT_UID_GID $ROOTFS/var/lib/dpkg/status
# Purge the network configuration from the container
rm $ROOTFS/etc/resolv.conf
