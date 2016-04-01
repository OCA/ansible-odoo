# Odoo [![Build Status](https://travis-ci.org/osiell/ansible-odoo.png)](https://travis-ci.org/osiell/ansible-odoo)

Ansible role to install Odoo from a Git or Mercurial repository,
and configure it.

Minimum Ansible Version: 2.0

## Supported versions and systems

| System / Odoo | 8.0 | 9.0 |
|---------------|-----|-----|
| Debian 7      | yes |  -  |
| Debian 8      | yes | yes |
| Ubuntu 12.04  | yes |  -  |
| Ubuntu 14.04  | yes | yes |

## Example (Playbook)

Standard installation (assuming that PostgreSQL is installed and running on
the same host):

```yaml
- name: Odoo
  hosts: odoo_server
  sudo: yes
  roles:
    - odoo
  vars:
    - odoo_version: 8.0
    - odoo_config_admin_passwd: SuPerPassWorD
```

Standard installation but with PostgreSQL installed on a remote host (and
available from your Ansible inventory):

```yaml
- name: Odoo
  hosts: odoo_server
  sudo: yes
  roles:
    - odoo
  vars:
    - odoo_version: 8.0
    - odoo_config_admin_passwd: SuPerPassWorD
    - odoo_config_db_host: pg_server
    - odoo_config_db_user: odoo
    - odoo_config_db_passwd: PaSsWoRd
```

Installation from a personnal Git repository such as your repository looks
like this:

```sh
REPO/
├── server              # could be a sub-repository of https://github.com/odoo/odoo
├── addons_oca_web      # another sub-repository (https://github.com/OCA/web here)
├── addons_oca_connector    # yet another sub-repository (https://github.com/OCA/connector)
└── addons              # custom modules
```

Here we set some options required by the ``connector`` framework:

```yaml
- name: Odoo
  hosts: odoo_server
  sudo: yes
  roles:
    - odoo
  vars:
    - odoo_version: 8.0
    - odoo_repo_type: git
    - odoo_repo_url: https://SERVER/REPO
    - odoo_repo_rev: master
    - odoo_repo_dest: "/home/{{ odoo_user }}/odoo"
    - odoo_init_env:
        ODOO_CONNECTOR_CHANNELS: root:2
    - odoo_config_admin_passwd: SuPerPassWorD
    - odoo_config_addons_path:
        - "/home/{{ odoo_user }}/odoo/server/openerp/addons"
        - "/home/{{ odoo_user }}/odoo/server/addons"
        - "/home/{{ odoo_user }}/odoo/addons_oca_web"
        - "/home/{{ odoo_user }}/odoo/addons_oca_connector"
        - "/home/{{ odoo_user }}/odoo/addons"
    odoo_config_server_wide_modules: web,web_kanban,connector
    odoo_config_workers: 8
```

## Variables

```yaml
odoo_service: odoo
odoo_version: 8.0
odoo_user: odoo
odoo_user_passwd: odoo
odoo_user_system: False
odoo_logdir: "/var/log/{{ odoo_user }}"
odoo_workdir: "/home/{{ odoo_user }}/odoo"
odoo_rootdir: "/home/{{ odoo_user }}/odoo/server"
odoo_init: True
odoo_init_env: {}
    #VAR1: value1
    #VAR2: value2
odoo_config_file: "/home/{{ odoo_user }}/{{ odoo_service }}.conf"
odoo_force_config: True
odoo_repo_type: git     # git or hg
odoo_repo_url: https://github.com/odoo/odoo.git
odoo_repo_dest: "{{ odoo_rootdir }}"
odoo_repo_rev: "{{ odoo_version }}"
odoo_repo_update: True  # Update the working copy or not. This option is
                        # ignored on the first run (a checkout of the working
                        # copy is always processed on the given revision)
                        # WARNING: uncommited changes will be discarded!
odoo_repo_depth: 1      # Set to 0 to clone the full history
                        # (option not supported with hg repository)
odoo_wkhtmltox_version: 0.12.1      # Download URLs available in the
                                    # 'odoo_wkhtmltox_urls' variable
                                    # (see 'vars/main.yml')
odoo_reportlab_font_url: http://www.reportlab.com/ftp/pfbfer.zip

# Tasks related to PostgreSQL
odoo_postgresql_set_user: True
odoo_postgresql_active_unaccent: True

# Odoo parameters
odoo_config_addons_path:
    - "/home/{{ odoo_user }}/odoo/server/openerp/addons"
    - "/home/{{ odoo_user }}/odoo/server/addons"
odoo_config_admin_passwd: admin
odoo_config_auto_reload: False
odoo_config_csv_internal_sep: ','
odoo_config_data_dir: "/home/{{ odoo_user }}/.local/share/Odoo"
odoo_config_db_host: False
odoo_config_db_host_user: "{{ ansible_ssh_user }}"
odoo_config_db_maxconn: 64
odoo_config_db_name: False
odoo_config_db_passwd: False
odoo_config_db_port: False
odoo_config_db_template: template1
odoo_config_db_user: odoo
odoo_config_dbfilter: '.*'
odoo_config_debug_mode: False
odoo_config_pidfile: None
odoo_config_proxy_mode: False
odoo_config_email_from: False
odoo_config_geoip_database: /usr/share/GeoIP/GeoLiteCity.dat
odoo_config_limit_memory_hard: 805306368
odoo_config_limit_memory_soft: 671088640
odoo_config_limit_time_cpu: 60
odoo_config_limit_time_real: 120
odoo_config_list_db: True
odoo_config_log_db: False
odoo_config_log_level: info
odoo_config_logfile: None
odoo_config_logrotate: False
odoo_config_longpolling_port: 8072
odoo_config_osv_memory_age_limit: 1.0
odoo_config_osv_memory_count_limit: False
odoo_config_max_cron_threads: 2
odoo_config_secure_cert_file: server.cert
odoo_config_secure_pkey_file: server.pkey
odoo_config_server_wide_modules: None
odoo_config_smtp_password: False
odoo_config_smtp_port: 25
odoo_config_smtp_server: localhost
odoo_config_smtp_ssl: False
odoo_config_smtp_user: False
odoo_config_syslog: False
odoo_config_timezone: False
odoo_config_translate_modules: ['all']
odoo_config_unaccent: False
odoo_config_without_demo: False
odoo_config_workers: 0
odoo_config_xmlrpc: True
odoo_config_xmlrpc_interface: ''
odoo_config_xmlrpc_port: 8069
odoo_config_xmlrpcs: True
odoo_config_xmlrpcs_interface: ''
odoo_config_xmlrpcs_port: 8071
# Custom configuration options
odoo_config_custom: {}
    #your_option1: value1
    #your_option2: value2

# Extra options
odoo_user_sshkeys: False    # ../../path/to/public_keys/*
```
