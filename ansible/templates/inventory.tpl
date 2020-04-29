[db_servers]
${hosts}

[db_servers:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_user=${user}
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
