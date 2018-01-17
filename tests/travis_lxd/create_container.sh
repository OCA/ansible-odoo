#!/bin/bash
HERE=$(dirname $(readlink -m $0))
CT_DIR="/var/lib/lxd/containers/$1"
# Spawn a LXD container
lxc init ${IMAGE} $1 -c security.privileged=true
lxc config set $1 raw.lxc "lxc.aa_allow_incomplete=1"
if [[ "$IMAGE" == 'images:debian/jessie' ]]; then
    $HERE/fix_debian_jessie.sh $1;
fi
lxc start $1 && sleep 4 && lxc list
# Configure the container
lxc config set $1 environment.ODOO_VERSION $ODOO_VERSION
lxc config set $1 environment.ODOO_INSTALL_TYPE $ODOO_INSTALL_TYPE
lxc config set $1 environment.ANSIBLE_VERSION $ANSIBLE_VERSION
# Copy the project files into the container
cp -av $HERE/../.. $CT_DIR/rootfs/opt/ansible-odoo
# Install the test environment
lxc exec $1 -- sh -c "/opt/ansible-odoo/tests/install_test_env.sh"
