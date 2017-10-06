#!/bin/bash
HERE=$(dirname $(readlink -m $0))
# Spawn a LXD container
lxc init ${IMAGE} $1
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
lxc file push -r -p $HERE/../.. $1/opt/
# Install the test environment
lxc exec $1 -- sh -c "/opt/ansible-odoo/tests/install_test_env.sh"
