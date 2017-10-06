#!/bin/bash
HERE=$(dirname $(readlink -m $0))
VENV=/opt/ansible-venv
GET_PIP_URL="https://bootstrap.pypa.io/get-pip.py"
# Install system dependencies
apt-get update -qq
apt-get install -qq python-virtualenv python-apt python-pip python-dev lsb-release wget ca-certificates
# Install Ansible in a virtual Python environment
virtualenv $VENV
wget $GET_PIP_URL -O $VENV/get-pip.py
$VENV/bin/python $VENV/get-pip.py
$VENV/bin/pip install "ansible>=$ANSIBLE_VERSION"
# Install PostgreSQL
apt-get install -qq postgresql postgresql-contrib
