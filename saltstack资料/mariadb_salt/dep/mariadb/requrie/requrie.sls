mysql-user:
  cmd.run:
    - name: useradd mysql -M -s /sbin/nologin
    - unless: grep mysql /etc/passwd

