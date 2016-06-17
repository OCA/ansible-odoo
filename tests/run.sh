#!/bin/sh
# Check the role/playbook's syntax.
ansible-playbook -i tests/inventory tests/test_$ODOO_INSTALL_TYPE.yml --syntax-check || exit 1
# Run the role/playbook with ansible-playbook.
ansible-playbook -i tests/inventory tests/test_$ODOO_INSTALL_TYPE.yml --connection=local --sudo -e "odoo_version=$ODOO_VERSION" || exit 1
sudo service odoo-$ODOO_INSTALL_TYPE status || exit 1
# Run the role/playbook again, checking to make sure it's idempotent.
output_log=$ODOO_VERSION_$ODOO_INSTALL_TYPE.log
ansible-playbook -i tests/inventory tests/test_${ODOO_INSTALL_TYPE}.yml --connection=local --sudo -e "odoo_version=$ODOO_VERSION" -v > $output_log || exit 1
grep -q 'changed=0.*failed=0' $output_log \
    && (echo 'IDEMPOTENCE TEST: OK' && exit 0) \
    || (echo 'IDEMPOTENCE TEST: FAILED' && cat $output_log && exit 1) || exit 1
sudo service odoo-$ODOO_INSTALL_TYPE status || exit 1
# Run the role/playbook again but change the configuration, and check if the service restart
ansible-playbook -i tests/inventory tests/test_${ODOO_INSTALL_TYPE}_changed.yml --connection=local --sudo -e "odoo_version=$ODOO_VERSION" -v > $output_log || exit 1
grep -q 'changed=2.*failed=0' $output_log \
    && (echo 'RESTART TEST: OK' && exit 0) \
    || (echo 'RESTART TEST: FAILED' && cat $output_log && exit 1) || exit 1
sudo service odoo-$ODOO_INSTALL_TYPE status || exit 1
sleep 3 && wget http://localhost:8069  | exit 1
sudo service odoo-$ODOO_INSTALL_TYPE stop  || exit 1
# Clean up
sudo rm -rf /home/odoo/odoo
