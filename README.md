Ansible Role: Docker Web Stack
=========

Starts a set of docker services on docker servers.



### Services

* PHP-FPM
* Maria DB
* phpMyAdmin
* Redis
* [postal](https://github.com/postalhq/postal)
* Certbot



Requirements
------------

Requires root access, docker and docker-compose.



Role Variables
--------------

A description of the settable variables for this role should go here, including any variables that are in defaults/main.yml, vars/main.yml, and any variables that can/should be set via parameters to the role. Any variables that are read from other roles and/or the global scope (ie. hostvars, group vars, etc.) should be mentioned here as well.





Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: username.rolename, x: 42 }

License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
