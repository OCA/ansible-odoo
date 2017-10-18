#!/bin/sh
HERE=$(dirname $(readlink -m $0))
cd $HERE/..
# Configure environment
export PAGER=cat
# Configure Ansible
cat <<EOF > ansible.cfg
[defaults]
roles_path = ../
[ssh_connection]
pipelining=True
EOF
echo "== CHECK THE ROLE/PLAYBOOK'S SYNTAX =="
ansible-playbook -i tests/inventory tests/test_$ODOO_INSTALL_TYPE.yml --syntax-check || exit 1

echo "== RUN THE ROLE/PLAYBOOK WITH ANSIBLE-PLAYBOOK =="
ansible-playbook -i tests/inventory tests/test_$ODOO_INSTALL_TYPE.yml --connection=local --become -e "odoo_version=$ODOO_VERSION" || exit 1
echo "== CHECK THE SERVICE STATUS =="
sudo -E service odoo-$ODOO_INSTALL_TYPE status || exit 1

echo "== RUN THE ROLE/PLAYBOOK AGAIN, CHECKING TO MAKE SURE IT'S IDEMPOTENT =="
output_log=$ODOO_VERSION_$ODOO_INSTALL_TYPE.log
ansible-playbook -i tests/inventory tests/test_${ODOO_INSTALL_TYPE}.yml --connection=local --become -e "odoo_version=$ODOO_VERSION" -v > $output_log || exit 1
grep -q 'changed=0.*failed=0' $output_log \
    && (echo 'IDEMPOTENCE TEST: OK' && exit 0) \
    || (echo 'IDEMPOTENCE TEST: FAILED' && cat $output_log && exit 1) || exit 1
echo "== CHECK THE SERVICE STATUS =="
sudo -E service odoo-$ODOO_INSTALL_TYPE status || exit 1

echo "== RUN THE ROLE/PLAYBOOK AGAIN BUT CHANGE THE CONFIGURATION AND CHECK IF THE SERVICE RESTART =="
ansible-playbook -i tests/inventory tests/test_${ODOO_INSTALL_TYPE}_changed.yml --connection=local --become -e "odoo_version=$ODOO_VERSION" -v > $output_log || exit 1
grep -q 'changed=2.*failed=0' $output_log \
    && (echo 'RESTART TEST: OK' && exit 0) \
    || (echo 'RESTART TEST: FAILED' && cat $output_log && exit 1) || exit 1

echo "== CHECK THE SERVICE STATUS =="
sudo -E service odoo-$ODOO_INSTALL_TYPE status || exit 1
sleep 3 && wget http://localhost:8069  | exit 1
sudo -E service odoo-$ODOO_INSTALL_TYPE stop  || exit 1
