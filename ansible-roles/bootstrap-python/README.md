This is a simple role to ensure that Python is installed so that the rest of Ansible can work. Use this by including this at the very beginning of your playbook:

~~~yaml
- hosts: all
  gather_facts: false
  roles:
    - role: bootstrap-python
~~~
