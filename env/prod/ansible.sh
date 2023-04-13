#!/bin/bash
cd /home/ubuntu
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
sudo python3 get-pip.py
sudo python3 -m pip install ansible
tee -a playbook.yml > /dev/null <<EOT
- hosts: localhost
  tasks: 
  - name: Instalando pyhton
    apt:
       pkg:
       - python3
       - virtualenv
       update_cache: yes
    become: yes
  - name: Git clone
    ansible.builtin.git:
      repo: https://github.com/guilhermeonrails/clientes-leo-api.git
      dest: /home/ubuntu/estudo
      version: master
      force: yes
  - name: Instalando dependencias com pip
    pip:
      virtualenv: /home/ubuntu/estudo/venv
      requirements: /home/ubuntu/estudo/requirements.txt
  - name: Alterando hosts do settings
    lineinfile:
      path: /home/ubuntu/estudo/setup/settings.py
      regexp: 'ALLOWED_HOSTS'
      line: 'ALLOWED_HOSTS = ["*"]'
      backrefs: yes
  - name: Configurando o banco de dados
    shell: '. /home/ubuntu/estudo/venv/bin/activate; python /home/ubuntu/estudo/manage.py migrate'
  - name: Carregando dados iniciais
    shell: '. /home/ubuntu/estudo/venv/bin/activate; python /home/ubuntu/estudo/manage.py loaddata clientes.json'
  - name: Iniciando o servidor
    shell: '. /home/ubuntu/estudo/venv/bin/activate; nohup python /home/ubuntu/estudo/manage.py runserver 0.0.0.0:8000 &'
EOT
ansible-playbook playbook.yml