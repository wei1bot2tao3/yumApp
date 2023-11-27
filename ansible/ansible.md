执行命令：
ansible-playbook -i /etc/ansible/hosts ls.yml


playbook基础    https://ansible-tran.readthedocs.io/en/latest/docs/playbooks_intro.html
---
- name: scp
  hosts: webservers
  become: yes  # 使用sudo提升权限

  tasks:
  - name: Copy from local to target
    copy:
    src: /root/nezha.sh  # 本地文件路径
    dest: /root/op/      # 目标文件夹路径

  - name: List files in /root/op/
    become: yes
    shell: ls /root/op/    # 运行ls命令列出目标文件夹内容
    register: ls_output    # 将ls命令的输出保存到ls_output变量

  - name: Display ls command output
    debug:
    var: ls_output.stdout_lines  # 输出ls命令的标准输出
