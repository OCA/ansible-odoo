# Odoo [![Build Status](https://travis-ci.org/osiell/ansible-odoo.png)](https://travis-ci.org/osiell/ansible-odoo)

Ansible role to install Odoo from a Git or Mercurial repository,
and configure it.

This role supports two types of installation:

* **standard**: install the Odoo dependencies from APT repositories and the
Odoo project from a Git/Hg repository. Odoo is configured with Ansible options
(`odoo_config_*` ones).

* **buildout**: build the Odoo project from a Git/Hg repository containing a
Buildout configuration file based on the
[anybox.recipe.odoo](https://pypi.python.org/pypi/anybox.recipe.odoo/) recipe.
Odoo and its dependencies are then installed and executed inside a Python
virtual environment. The configuration part is also managed by Buildout
(`odoo_config_*` options are not used excepting the `odoo_config_db_*` ones
for PostgreSQL related tasks).

Minimum Ansible Version: 2.1

## Supported versions and systems

### Standard (odoo_install_type: standard)

| System / Odoo | 8.0 | 9.0 | 10.0 |
|---------------|-----|-----|------|
| Debian 7      | yes |  -  |  -   |
| Debian 8      | yes | yes | yes  |
| Ubuntu 12.04  | yes |  -  |  -   |
| Ubuntu 14.04  | yes | yes | yes  |
| Ubuntu 16.04  | yes | yes | yes  |

### Buildout (odoo_install_type: buildout)

You only need a Debian-based system, all the stuff is then handled by Buildout
to run Odoo >= 8.0.

## Example (Playbook)

### odoo_install_type: standard (default)

Standard installation (assuming that PostgreSQL is installed and running on
the same host):

```yaml
- name: Odoo
  hosts: odoo_server
  become: yes
  roles:
    - odoo
  vars:
    - odoo_version: 10.0
    - odoo_config_admin_passwd: SuPerPassWorD
```

With the standard installation type you configure Odoo with the available
`odoo_config_*` options.

Standard installation but with PostgreSQL installed on a remote host (and
available from your Ansible inventory):

```yaml
- name: Odoo
  hosts: odoo_server
  become: yes
  roles:
    - odoo
  vars:
    - odoo_version: 10.0
    - odoo_config_admin_passwd: SuPerPassWorD
    - odoo_config_db_host: pg_server
    - odoo_config_db_user: odoo
    - odoo_config_db_passwd: PaSsWoRd
```

Standard installation from a personnal Git repository such as your repository
looks like this:

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
  become: yes
  roles:
    - odoo
  vars:
    - odoo_version: 10.0
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

### odoo_install_type: buildout

With a Buildout installation type, Odoo is installed and configured directly
by Buildout:

```yaml
- name: Odoo
  hosts: odoo_server
  become: yes
  roles:
    - odoo
  vars:
    - odoo_install_type: buildout
    - odoo_version: 10.0
    - odoo_repo_type: git
    - odoo_repo_url: https://github.com/osiell/odoo-buildout-example.git
    - odoo_repo_rev: "{{ odoo_version }}"
    - odoo_repo_dest: "/home/{{ odoo_user }}/odoo"
```

The same but with PostgreSQL installed on a remote host (and available from
your Ansible inventory):

```yaml
- name: Odoo
  hosts: odoo_server
  become: yes
  roles:
    - odoo
  vars:
    - odoo_install_type: buildout
    - odoo_version: 10.0
    - odoo_repo_type: git
    - odoo_repo_url: https://github.com/osiell/odoo-buildout-example.git
    - odoo_repo_rev: "{{ odoo_version }}"
    - odoo_repo_dest: "/home/{{ odoo_user }}/odoo"
    - odoo_config_db_host: pg_server
    - odoo_config_db_user: odoo
    - odoo_config_db_passwd: PaSsWoRd
```

By default Ansible is looking for a `bootstrap.py` script and a `buildout.cfg`
file at the root of the cloned repository to call Buildout, but you can change
that to point to your own files. Assuming your repository looks like this:

```sh
REPO/
├── addons              # custom modules
├── bin
│   └── bootstrap.py
├── builtout.cfg
├── builtout.dev.cfg
├── builtout.prod.cfg
└── builtout.test.cfg
```

We just set the relevant options to tell Ansible the files to use with the
`odoo_buildout_*` options:

```yaml
- name: Odoo
  hosts: odoo_server
  become: yes
  roles:
    - odoo
  vars:
    - odoo_install_type: buildout
    - odoo_version: 10.0
    - odoo_repo_type: git
    - odoo_repo_url: https://SERVER/REPO
    - odoo_repo_rev: master
    - odoo_repo_dest: "/home/{{ odoo_user }}/odoo"
    - odoo_buildout_bootstrap_path: "/home/{{ odoo_user }}/odoo/bin/bootstrap.py"
    - odoo_buildout_config_path: "/home/{{ odoo_user }}/odoo/buildout.prod.cfg"
```

## Variables

See the [defaults/main.yml](defaults/main.yml) file.
