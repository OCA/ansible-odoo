#!/bin/sh
HERE=$(dirname $(readlink -m $0))
VENV=/opt/ansible-venv
CMD="$VENV/bin/ansible-playbook -i tests/inventory"
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
$CMD tests/test_$ODOO_INSTALL_TYPE.yml --syntax-check || exit 1

echo "== RUN THE ROLE/PLAYBOOK WITH ANSIBLE-PLAYBOOK =="
$CMD tests/test_$ODOO_INSTALL_TYPE.yml --connection=local --become -e "odoo_version=$ODOO_VERSION" || exit 1
echo "== CHECK THE SERVICE STATUS =="
sudo -E service odoo-$ODOO_INSTALL_TYPE status || exit 1

echo "== RUN THE ROLE/PLAYBOOK AGAIN, CHECKING TO MAKE SURE IT'S IDEMPOTENT =="
output_log=$ODOO_VERSION_$ODOO_INSTALL_TYPE.log
$CMD tests/test_${ODOO_INSTALL_TYPE}.yml --connection=local --become -e "odoo_version=$ODOO_VERSION" -v > $output_log || exit 1
grep -q 'changed=0.*failed=0' $output_log \
    && (echo 'IDEMPOTENCE TEST: OK' && exit 0) \
    || (echo 'IDEMPOTENCE TEST: FAILED' && cat $output_log && exit 1) || exit 1
echo "== CHECK THE SERVICE STATUS =="
sudo -E service odoo-$ODOO_INSTALL_TYPE status || exit 1

echo "== RUN THE ROLE/PLAYBOOK AGAIN BUT CHANGE THE CONFIGURATION AND CHECK IF THE SERVICE RESTART =="
$CMD tests/test_${ODOO_INSTALL_TYPE}_changed.yml --connection=local --become -e "odoo_version=$ODOO_VERSION" -v > $output_log || exit 1
grep -q 'changed=2.*failed=0' $output_log \
    && (echo 'RESTART TEST: OK' && exit 0) \
    || (echo 'RESTART TEST: FAILED' && cat $output_log && exit 1) || exit 1

echo "== CHECK THE SERVICE STATUS =="
sudo -E service odoo-$ODOO_INSTALL_TYPE status || exit 1
sleep 3 && if ! wget http://localhost:8069; then tail -n 100 /var/log/odoo/*.log && exit 1; fi
sudo -E service odoo-$ODOO_INSTALL_TYPE stop || exit 1

echo "== CHECK WKHTMLTOPDF =="
wkhtmltopdf --version
