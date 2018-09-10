ansible-lxd-odoo
================

Ansible is an IT automation tool. In this project, "Ansible LXD Odoo", we use it to automate the installation and configuration of Odoo in an LXD container.

Ansible layout
--------------

### Working folder

In any working folder we have:

`ansible.cfg`: Configuration file.

`hosts`: File that has the names of nodes that we can access by ssh or lxd protocol or any protocol that Ansible supports

`playbook.yml`: In this file we tell Ansible: please install roles on some nodes. We can manipulate Ansible roles by putting some variables here. We can store many Playbook YML files in ansible working folder, that with different name indicates why we use it (eg. buildout.yml, create_container.yml, config_db.yml) and run these as single files in a single comand as to what we need.

`roles`: Inside this folder we must have at least one role folder, like 'ansible-odoo'.

### Role folders

In a role folder we have the following:

`tasks`: Required folder that contains the main actions to be done in this role. `tasks/main.yml` is the tasks entry point.

`vars`: Folder that contains the variables for this role. Variables allow tasks to choose between different behaviours, based on the situation.

`defaults`: Contains the defaults for variables in this role. `defaults/main.yml` is the entry point.

`files`: This directory holds files that can be copied as-is on the remote nodes.

`templates`: This directory holds files (templates) that still need some variables to be filled in before copying to the remote node.

Installation
------------

### Remote server

NB. for testing purposes, the remote server can be `localhost`!

The remote server should be Ubuntu, because it's the only Linux that currently supports LXC. The configuration of the server is done by Ansible.

Should you wish to install LXC manually:

```
sudo apt-get install lxc
```

### Control server

NB. for testing purposes, the control server can be `localhost`! When working as a single person, you could even stick with controlling your remote server(s) from localhost indefinitely.

#### Installing Ansible

The control server runs Ansible. We should install it by:

```
sudo apt-get update
sudo apt-get install software-properties-common
sudo apt-add-repository ppa:ansible/ansible
sudo apt-get update
sudo apt-get install ansible
```

Then we copy /etc/ansible folder to home directory, and edit ansible.cfg file clear all lines in it and put this line:

```
[defaults]
inventory = hosts
enable_task_debugger = True
```

Then we edit `hosts` file.
Clear all lines in it and put `localhost` or the name of your remote server. When using Ansible in `paramiko` or `ssh` mode, it is allowed to use names that refer to shortcut configurations from your `$HOME/.ssh/config` file.

#### Installing the Ansible LXD Odoo role

We `git clone` our repository in the roles folder:

```
cd roles
git clone https://github.com/sunflowerit/ansible-odoo
git checkout 431-latest-work
```

Usage
-----

### Example: default setup

Touch `default.yml` in ansible works directory and put these lines into it:

```
- name: Odoo
  hosts: localhost
  connection: local
  become: yes
  roles:
    - role: ansible-odoo
```

then run this command: `ansible-playbook -K default.yml`

By this command ansible runs with default variables so the roles will do these steps:

1. Create LXD container: `lxdcontainer` and put `lxdcontainer ansible_connection=lxd` line in ansible inventory hosts file `hosts` to make `lxdcontainer` available in ansible environment
2. Copy id_rsa from the .ssh folder in home server user folder: /home/odoo/.ssh/id_rsa to the .ssh folder in home container user folder: /home/ubuntu/.ssh/
3. Change container network type from DHCP mode to static IP mode with same 'lxdcontainer' setting that given it by DHCP.
4. Install postgresql into lxdcontainer, and create user: 'ubuntu' into postgresql with password: 'password' and with (NOCREATE, NOSUBERUSER) rights.
5. Create database: 'odoodatabase', and grant 'ubuntu' to be owner of 'odoodatabase'.
6. Install some packages: `sudo`, `git`, `mercurial`, `python-pip`, `python-psycopg2`, `nl_NL.UTF-8`. in LXD container.
7. Download branch 9.0 from repository `https://github.com/sunflowerit/custom-installations/tree/9.0-custom-standard`
8. Install some packages: `build-essential`, `python-dev`, `libxml2-dev`, `libxslt1-dev`,  `libpq-dev`, `libldap2-dev`, `libsasl2-dev`, `libopenjp2-7-dev`, `libjpeg-turbo8-dev`, `libtiff5-dev`, `libfreetype6-dev`, `liblcms2-dev`, `libwebp-de`.
9. Create `/home/ubuntu/odoo/local.cfg` in container OS. the default content of local.cfg is:

```
[buildout]
extends = odoo8-standard.cfg

[odoo]
options.admin_passwd = admin
options.db_host = localhost
options.db_name = odoodatabase
options.db_port = 5432
options.db_user = ubuntu
options.db_password = password
options.xmlrpc_port = 8069
options.longpolling_port = 8072
```

10. Run this command: `/usr/bin/python /home/ubuntu/odoo/bootstrap.py -c /home/ubuntu/odoo/local.cfg --buildout-version 2.11.4` 
11. Install setuptools version: `38.1.0`
12. Download https://raw.githubusercontent.com/odoo/odoo/8.0/requirements.txt
13. install pip pkg that in requirements.txt.
14. run this command: /home/ubuntu/odoo/bin/buildout -c /home/ubuntu/odoo/local.cfg
15. then install `less`, `less-plugin-clean-css`, `phantomjs-prebuilt` if we build odoo 9.0 or 10.0
16. Download `wkhtmltox`
17. Install wkhtmltox dependencies and wkhtmltox 'generic package'
18. Download the ReportLab barcode fonts then unzip it
19. Generate odoo service files
20. create /etc/nginx/sites-available/lxdcontainer.sunflowerodoo.nl, the default content in lxdcontainer.sunflowerodoo.nl is:

```
  server {
  listen 80;
  server_name lxdcontainer.sunflowerodoo.nl;

  client_max_body_size 200M;

  proxy_connect_timeout       6000s;
  proxy_send_timeout          6000s;
  proxy_read_timeout          6000s;
  send_timeout                6000s;

  proxy_set_header   Host      $http_host;
  proxy_set_header   X-Real-IP $remote_addr;
  proxy_set_header   X-Forward-For $proxy_add_x_forwarded_for;

  location / {
    proxy_pass http://{{ odoo_ip }}:8069;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Scheme $scheme;
    proxy_connect_timeout 600;
    proxy_send_timeout 600;
    proxy_read_timeout 600;

  }

  location /longpolling {
    proxy_pass http://{{ odoo_ip }}:8072;
  }

}
```

21. Make a link in `/etc/nginx/sites-enabled/lxdcontainer.sunflowerodoo.nl` to `/etc/nginx/sites-available/lxdcontainer.sunflowerodoo.nl`
22. Try to reload nginx by this command: `nginx -t && nginx -s reload`

### Example 2: modified setup

Now we can change ansible-playbook behavior by put some variable value in playbook.yml.

For example, to make a new container and give it simple odoo10 and install odoo 10.0 inside this container from 10.0-custom-standard branch and configure nginx to make this container available in simpleodoo10.sunflowerodoo.nl we touch odoo_10_default.yml in ansible working directory and edit it to be:

```
- name: Odoo
  hosts: localhost
  connection: local
  become: yes
  roles:
    - role: ansible-odoo
      odoo_version: 10.0
      odoo_config_db_name: odoodatabase
      lxd_container_name: simpleodoo10
      branch: 10.0-custom-standard
```

Then we run this command:

`ansible-playbook -K odoo_10_default.yml`

### Example 3: modified setup

To create a new container 'cleanlxdcontainer', install postgres with and create 'simpleuser' user with 'TlTtLLtt' password in database and grant it to have CREATEDB,SUPERUSER without creat database and without download odoo and without install odoo and without config nginx we touch simple_lxd.yml and edit it to be:

```
- name: Odoo
  hosts: localhost
  connection: local
  become: yes
  roles:
    - role: ansible-odoo
      lxd_container_name: cleanlxdcontainer
      new_postgresql_db: false
      odoo_config_db_user: simpleuser
      odoo_config_db_passwd: TlTtLLtt
      odoo_config_db_user_righs: "CREATEDB,SUPERUSER"
      buildout_step: false
      nginx_step: false
```

Then we run this command:

`ansible-playbook -K simple_lxd.yml`

### Example 4: modified setup

For example we can move some database to 'cleanlxdcontainer', and then we need to install odoo 10.0 from branch 9.0-custom-standard with custom buildout file we had before like custom.cfg. We plan to use buildout version 2.8.0, and build it to use the database 'somedatabase' we moved it to container manually before. We plan to ignore installing `less` and the `reportlab` packages, and we need to make odoo available on xmlrpc port '8090' and on longpolling port '8095' and configure nginx to make this container availabe in test.sunflowerodoo.nl.

Then, wwe must put custom.cfg in roles/files/odoo_config_files/ and edit simple_lxd.yml in ansible works directory to be:

```
- name: Odoo
  hosts: localhost
  connection: local
  become: yes
  roles:
    - role: ansible-odoo
      lxd_container_name: cleanlxdcontainer
      lxd_step: false
      odoo_version: 10.0
      buildout_config_file: custome.cfg
      github_account: [ your accont on github allow you to acces to sunflower instance ]
      github_account_name: [ your name ]
      odoo_buildout_version: 2.8.0
      odoo_config_db_user: simpleuser
      odoo_config_db_passwd: TlTtLLtt
      app_after_buildout: false
      buildout_step: true
      nginx_step: true
      nginx_subdomain: test
      odoo_config_xmlrpc_port: 8090
      odoo_config_longpolling_port: 8095
then we run this command
ansible-playbook -K -e new_lxd_container=false simple_lxd.yml
```

### Example 5: modified setup

if we plan to create 'customuser' container and creat 'customer' system user with 'wQrEyTuY' password and with vertual enviroment in that container and install postgresql with default 'odoodatabase' database and default database user and password and downlowad odoo 8.0 from bransh 9.0-custom-standard but without run bootstrap and without run buildout and make it avialable at customuser.sunflowerserver.nl we touch customer.yml and edit it to be:

```
- name: Odoo
  hosts: localhost
  connection: local
  become: yes
  roles:
    - role: ansible-odoo
      odoo_version: 8.0
      lxd_container_name: customuser
      odoo_user: customer
      odoo_user_passwd: wQrEyTuY
      env_type: true
      run_bootstrap: false
      run_buildout: false
      nginx_domain: sunflowerserver.nl
then we run this command
ansible-playbook -K customer.yml
```

### Example 6: modified setup

Now if we plan to install default odoo 10.0 directly on server and create 'odoouser' system user with 'SaFdHgKj' password for that and install odoo 10.0 in vertual inviroment and config it to be available on xmlrpc port '8016' and on longpolling port '8019' and config nginx to make this container available at odoo10local.sunflowerodoo.nl we touch odoo10local.yml and edit it to be:

```
- name: Odoo
  hosts: localhost
  connection: local
  become: yes
  roles:
    - role: ansible-odoo
      odoo_version: 10.0
      lxd_type: false
      odoo_user: odoouser
      odoo_user_passwd: SaFdHgKj
      env_type: true
      nginx_subdomain: odoo10local
      odoo_config_xmlrpc_port: 8016
      odoo_config_longpolling_port: 8019
```

