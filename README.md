# Odoo

Ansible role to install Odoo from a Git or Mercurial repository,
and configure it.

## Systems supported

- Debian Wheezy (7.0)
- Ubuntu Precise (12.04)
- Ubuntu Trusty (14.04)

## Variables

```yaml
odoo_service: odoo
odoo_version: 8.0
odoo_user: odoo
odoo_user_passwd: odoo
odoo_logdir: "/var/log/{{ odoo_user }}"
odoo_workdir: "/home/{{ odoo_user }}/odoo"
odoo_rootdir: "/home/{{ odoo_user }}/odoo/server"
odoo_init: True
odoo_databases: []      # [{name: prod, locale: 'en_US.UTF-8'}]
odoo_config_file: "/home/{{ odoo_user }}/{{ odoo_service }}.conf"
odoo_force_config: False
odoo_repo_type: git     # git or hg
odoo_repo_url: https://github.com/odoo/odoo.git
odoo_repo_dest: "{{ odoo_rootdir }}"
odoo_repo_rev: 8.0

# Odoo parameters
odoo_config_admin_passwd: admin
odoo_config_addons_path: "/home/{{ odoo_user }}/odoo/server/addons,/home/{{ odoo_user }}/odoo/server/openerp/addons"
odoo_config_auto_reload: False
odoo_config_data_dir: "/home/{{ odoo_user }}/.local/share/Odoo"
odoo_config_db_host: False
odoo_config_db_host_user: "{{ ansible_ssh_user }}"
odoo_config_db_port: False
odoo_config_db_user: odoo
odoo_config_db_passwd: False
odoo_config_dbfilter: '.*'
odoo_config_proxy_mode: False
odoo_config_unaccent: True
odoo_config_workers: 0
odoo_config_xmlrpc_port: 8069
odoo_config_xmlrpcs_port: 8071

# Extra options
odoo_user_sshkeys: False    # ../../path/to/public_keys/*
```


## Example (Playbook)

```yaml
- name: Odoo Server
  hosts: odoo_server
  sudo: yes
  roles:
    - odoo
  vars:
    - odoo_config_db_host: pg_server
    - odoo_config_db_user: odoo
    - odoo_repo_type: git
    - odoo_repo_url: https://github.com/odoo/odoo.git
    - odoo_repo_dest: /home/odoo/odoo/server
    - odoo_repo_rev: 8.0
```

When deploying, you can set the passwords with the `--extra-vars` option:

```sh
$ ansible-playbook -i servers servers.yml -l odoo_server --extra-vars "odoo_user_passwd=pAssWorD odoo_config_admin_passwd=SuPerPassWorD odoo_config_db_passwd=PaSswOrd"
```
