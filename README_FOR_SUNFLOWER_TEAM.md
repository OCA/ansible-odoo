# Odoo 

Ansible is an IT automation tool. so we deploy ansible-playbook to automate install and config odoo in LXD container.
ansible layout:

## ansible work directory:
in ansible work directory we moust have three files (ansible.cfg; hosts; playbook.yml) and one folder (moust have 'roles' name) 
inclod 'roles' folder we moust have role folder like 'ansible-odoo' in this folder moust we have on folder at list have 'tasks' name and aditional folders like (default; vars; files etc)

* **ansible.cfg**: is config file so in this toturial we bouild ansible cfg lines to be:

* **hosts**: hosts file is file stor the names of nodes can we access to it by ssh or lxd protocol or any protocol ansibile support it

* **playbook.yml**: playbook.yml is where you basically tell Ansible: please install roles on some nodes. and we can manipulate ansible roles by put some varibles in playbook.yml and we can store many playbook.yml files in ansible works directory that with different name indicates why we use it like (buildout.yml, creat_container.yml; config_db.yml etc) and run single file in single comand as what we need

* **defaults/main.yml**:
This directory contains defaults for variables used in roles. I encourage you to discover every variable we put in our role

* **tasks/main.yml**:
This file is the tasks entry point. the best way to discover our roles in this tutorial is starting analysis tasks in this file




* **files/**:
This directory holds files can be copied as-is on the remote nodes.

* **vars**:
this folder include variables preference allow tasks to choose between it occurred play satiation

## Supported versions and systems

| System / Odoo | 8.0 | 9.0 | 10.0 | 11.0 | LXD  |
|---------------|-----|-----|------|------|------|
| Debian 8      | yes | yes | yes  |  -   |  -   |
| Debian 9      | yes | yes | yes  | yes  |  -   |
| Ubuntu 14.04  | yes | yes | yes  |  -   | yes  |
| Ubuntu 16.04  | yes | yes | yes  | yes  | yes  |

## Example (Playbook)

to use this ansible roles we must copy /etc/ansible folder to home directory then edit ansible.cfg file clear all lins in it and put this line:
[defaults]
inventory = hosts
enable_task_debugger = True
then edit hosts file clear all lins in it and put this line:
localhost 

then git clone our repository in roles folder:
git clone
then touch default.yml in ansible works directory and put this lines into it:
```yaml
- name: Odoo
  hosts: localhost
  connection: local
  become: yes
  roles:
    - role: ansible-odoo
```

then run this command
ansible-playbook -K default.yml

by this command ansible run in default variables so the roles will do that steps:

1- create LXD container: 'lxdcontainer' and put "lxdcontainer ansible_connection=lxd" line in ansible inventory hosts file 'hosts' to make 'lxdcontainer' available in ansible enviroment

2- copy id_rsa from the .ssh folder in home server user folder: /home/odoo/.ssh/id_rsa to the .ssh folder in home container user folder: /home/ubuntu/.ssh/

3- change container network type from DHCP mode to static IP maode with same 'lxdcontainer' setting that given it by DHCP.

4- install postgresql into lxdcontainer, and creat user: 'ubuntu' into postgresql with password: 'password' and with (NOCREATE, NOSUBERUSER) rights.

5- creat database: 'odoodatabase', and grant 'ubuntu' to be owner of 'odoodatabase'.

6- install some pkg: (sudo; git; mercurial; python-pip; python-psycopg2; nl_NL.UTF-8) in LXD container OS

7- download bransh 9.0 from sunflower repository "https://github.com/sunflowerit/custom-installations/tree/9.0-custom-standard"

8- install some pkg: ( build-essential; python-dev; libxml2-dev; libxslt1-dev; libpq-dev; libldap2-dev; libsasl2-dev; libopenjp2-7-dev; libjpeg-turbo8-dev; libtiff5-dev; libfreetype6-dev; liblcms2-dev; libwebp-de)

9- creat /home/ubuntu/odoo/local.cfg in container OS. the default containt in local.cfg is:
```
   [buildout]"
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
10- run this command: /usr/bin/python /home/ubuntu/odoo/bootstrap.py -c /home/ubuntu/odoo/local.cfg --buildout-version 2.11.4 

11- install setuptools version: 38.1.0

12- download https://raw.githubusercontent.com/odoo/odoo/8.0/requirements.txt

13- install pip pkg that in requirements.txt

14- run this command: /home/ubuntu/odoo/bin/buildout -c /home/ubuntu/odoo/local.cfg

15- then install (less; less-plugin-clean-css; phantomjs-prebuilt) if we build odoo 9.0 or 10.0

16- Download wkhtmltox

17- Install wkhtmltox dependencies and wkhtmltox 'generic package'

18- Download the ReportLab barcode fonts then unzip it

19- Generate odoo service files

20- create /etc/nginx/sites-available/lxdcontainer.sunflowerodoo.nl, the default containt in lxdcontainer.sunflowerodoo.nl is:
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
    
      location /lonngpolling { 
        proxy_pass http://{{ odoo_ip }}:8072;
      }  
    
    } 


21- Make link in /etc/nginx/sites-enabled/lxdcontainer.sunflowerodoo.nl to /etc/nginx/sites-available/lxdcontainer.sunflowerodoo.nl

22- try to reload nginx by this command: nginx -t && nginx -s reload

now we can tchange ansible-playbook behavier by put some variable value in blaybook.yml
for example
to make a new container and giv it simpleodoo10 and install odoo 10.0 inside this container from 10.0-custom-standard bransh and config nginx to make this container available in simpleodoo10.sunflowerodoo.nl we touch odoo_10_default.yml in ansible works directory and edit it to be:
```yaml
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

then we run this command
ansible-playbook -K odoo_10_default.yml

to create a new container 'cleanlxdcontainer' install postgres with and create 'simpleuser' user with 'TlTtLLtt' password in database and grant it to have CREATEDB,SUPERUSER without creat database and without download odoo and without install odoo and without config nginx we touch simple_lxd.yml and edit it to be:
```yaml
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
then we run this command
ansible-playbook -K simple_lxd.yml

for example we can move some data base to 'cleanlxdcontainer' and then we need to install odoo 10.0 from bransh 9.0-custom-standard with custom buildout file we have before like custome.cfg and we plane to use buildout version 2.8.0 and make build it to use the database 'somedatabase' we moved it to container manaiualy befor and we plan to ignore installing (less; less-plugin-clean-css; phantomjs-prebuilt; wkhtmltox; ReportLab barcode fonts) and we need to make odoo able on xmlrpc port '8090' and on longpolling port '8095' and config nginx to make this container availabe in test.sunflowerodoo.nl we must put custom.cfg in roles/files/odoo_config_files/ and edit simple_lxd.yml in ansible works directory to be:
```yaml
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
```
then we run this command
ansible-playbook -K simple_lxd.yml

if we plane to create 'customuser' container and creat 'customer' system user with 'wQrEyTuY' password and with vertual enviroment in that container and install postgresql with default 'odoodatabase' database and default database user and password and downlowad odoo 8.0 from bransh 9.0-custom-standard but without run bootstrap and without run buildout and make it avialable at customuser.sunflowerserver.nl we touch customer.yml and edit it to be:
```yaml
- name: Odoo
  hosts: localhost
  connection: local
  become: yes
  roles:
    - role: ansible-odoo
      odoo_version: 8.0
      lxd_container_name: customuser
      new_lxd_container: False
      odoo_user: customer
      odoo_user_passwd: wQrEyTuY
      env_type: true
      run_bootstrap: false
      run_buildout: false
      nginx_domain: sunflowerserver.nl
```
then we run this command
ansible-playbook -K customer.yml

now if we plan to install default odoo 10.0 directly on server and creat 'odoouser' system user with 'SaFdHgKj' password for that and install odoo 10.0 in vertual inviroment and config nginx to make this container available at odoo10local.sunflowerodoo.nl we touch odoo10local.yml and edit it to be:
```yaml
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

