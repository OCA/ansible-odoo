# Odoo [![Build Status](https://travis-ci.org/OCA/ansible-odoo.png)](https://travis-ci.org/OCA/ansible-odoo)

Ansible role to install Odoo from a Git or Mercurial repository, or from pip,
and configure it.

This role supports three types of installation:

* **standard**: install the Odoo dependencies from APT repositories and the
Odoo project from a Git/Hg repository. Odoo is configured with Ansible options
(`odoo_config_*` ones).

* **pip**: install Odoo and its dependencies (modules and Python packages)
from a pip requirements.txt file. Odoo is configured with  Ansible options
(`odoo_config_*` ones).

* **buildout**: build the Odoo project from a Git/Hg repository containing a
Buildout configuration file based on the
[anybox.recipe.odoo](https://pypi.python.org/pypi/anybox.recipe.odoo/) recipe.
Odoo and its dependencies are then installed and executed inside a Python
virtual environment. The configuration part is also managed by Buildout
(`odoo_config_*` options are not used excepting the `odoo_config_db_*` ones
for PostgreSQL related tasks).

Minimum Ansible Version: 2.4

## Supported versions and systems

| System / Odoo | 8.0 | 9.0 | 10.0 | 11.0 |
|---------------|-----|-----|------|------|
| Debian 8      | yes | yes | yes  |  -   |
| Debian 9      | yes | yes | yes  | yes  |
| Ubuntu 14.04  | yes | yes | yes  |  -   |
| Ubuntu 16.04  | yes | yes | yes  | yes  |

## Example (Playbook)

### odoo_install_type: standard (default)

Standard installation (assuming that PostgreSQL is installed and running on
the same host):

```yaml
- name: Odoo
  hosts: odoo_server
  become: yes
  roles:
    - role: odoo
      odoo_version: 11.0
      odoo_config_admin_passwd: SuPerPassWorD
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
    - role: odoo
      odoo_version: 11.0
      odoo_config_admin_passwd: SuPerPassWorD
      odoo_config_db_host: pg_server
      odoo_config_db_user: odoo
      odoo_config_db_passwd: PaSsWoRd
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
    - role: odoo
      odoo_version: 11.0
      odoo_repo_type: git
      odoo_repo_url: https://SERVER/REPO
      odoo_repo_rev: master
      odoo_repo_dest: "/home/{{ odoo_user }}/odoo"
      odoo_init_env:
        ODOO_CONNECTOR_CHANNELS: root:2
      odoo_config_admin_passwd: SuPerPassWorD
      odoo_config_addons_path:
        - "/home/{{ odoo_user }}/odoo/server/openerp/addons"
        - "/home/{{ odoo_user }}/odoo/server/addons"
        - "/home/{{ odoo_user }}/odoo/addons_oca_web"
        - "/home/{{ odoo_user }}/odoo/addons_oca_connector"
        - "/home/{{ odoo_user }}/odoo/addons"
      odoo_config_server_wide_modules: web,web_kanban,connector
      odoo_config_workers: 8
```

### odoo_install_type: pip

Pip installation (assuming that PostgreSQL is installed and running on
the same host). We need to ensure that the environment variable LC_ALL is used
if Odoo version 11 is to be used:

```yaml
- name: Odoo
  hosts: odoo_server
  become: yes
  roles:
    - role: odoo
      odoo_install_type: pip
      odoo_version: 11.0
      odoo_pip_requirements_url: https://raw.githubusercontent.com/OCA/sample-oca-pip-requirements/11.0/requirements.txt
      odoo_config_admin_passwd: SuPerPassWorD
  environment:
    LC_ALL: en_US.UTF-8

```


### odoo_install_type: buildout

With a Buildout installation type, Odoo is installed and configured directly
by Buildout:

```yaml
- name: Odoo
  hosts: odoo_server
  become: yes
  roles:
    - role: odoo
      odoo_install_type: buildout
      odoo_version: 11.0
      odoo_repo_type: git
      odoo_repo_url: https://github.com/osiell/odoo-buildout-example.git
      odoo_repo_rev: "{{ odoo_version }}"
      odoo_repo_dest: "/home/{{ odoo_user }}/odoo"
```

The same but with PostgreSQL installed on a remote host (and available from
your Ansible inventory):

```yaml
- name: Odoo
  hosts: odoo_server
  become: yes
  roles:
    - role: odoo
      odoo_install_type: buildout
      odoo_version: 11.0
      odoo_repo_type: git
      odoo_repo_url: https://github.com/osiell/odoo-buildout-example.git
      odoo_repo_rev: "{{ odoo_version }}"
      odoo_repo_dest: "/home/{{ odoo_user }}/odoo"
      odoo_config_db_host: pg_server
      odoo_config_db_user: odoo
      odoo_config_db_passwd: PaSsWoRd
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
    - role: odoo
      odoo_install_type: buildout
      odoo_version: 11.0
      odoo_repo_type: git
      odoo_repo_url: https://SERVER/REPO
      odoo_repo_rev: master
      odoo_repo_dest: "/home/{{ odoo_user }}/odoo"
      odoo_buildout_bootstrap_path: "/home/{{ odoo_user }}/odoo/bin/bootstrap.py"
      odoo_buildout_config_path: "/home/{{ odoo_user }}/odoo/buildout.prod.cfg"
```

## Variables

See the [defaults/main.yml](defaults/main.yml) file.

## Bug Tracker

Bugs are tracked on [GitHub Issues](
https://github.com/OCA/ansible-odoo/issues).  In case of trouble, please
check there if your issue has already been reported. If you spotted it first,
help us smash it by providing detailed and welcomed feedback.

## Credits

### Contributors

* Sébastien Alix
* Jordi Ballester Alomar

Do not contact contributors directly about support or help with technical issues.


### Maintainer

[![Odoo Community Association](
https://odoo-community.org/logo.png)](https://odoo-community.org)

This module is maintained by the OCA.

OCA, or the Odoo Community Association, is a nonprofit organization whose
mission is to support the collaborative development of Odoo features and
promote its widespread use.

To contribute to this module, please visit https://odoo-community.org.

## Licence

This project is licensed under the terms of the GPLv3 license.
