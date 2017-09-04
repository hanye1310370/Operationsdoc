include:
  - mariadb.requrie.requrie
mariadb-install:
  file.managed:
    - name: /usr/local/src/mariadb-10.2.7-linux-x86_64.tar.gz
    - source: salt://mariadb/file/mariadb-10.2.7-linux-x86_64.tar.gz
    - mode: 755
    - user: root
    - group: root
  cmd.run:
    - name: cd /usr/local/src/ && tar xf mariadb-10.2.7-linux-x86_64.tar.gz -C /usr/local/  && ln -s /usr/local/mariadb-10.2.7-linux-x86_64 /usr/local/mysql && cd /usr/local/mysql  && chown -R mysql.mysql /usr/local/mysql/ && /usr/local/mysql/scripts/mysql_install_db --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data --user=mysql && cp bin/{mysql,mysqladmin,mysqldump} /usr/local/sbin/ && cp support-files/mysql.server /etc/init.d/mysqld && chmod +x /etc/init.d/mysqld
    - requrie:
      - file: mariadb-install
    - unless: test -L /usr/local/mysql

mariadb-config:
  file.managed:
    - name: /etc/my.cnf
    - source: salt://mariadb/file/my.cnf.temple
    - user: mysql
    - group: mysql
    - mode: 755

mariadb-service:
  cmd.run:
    - name: chkconfig --add mysqld && chkconfig mysqld on
    - unless: chkconfig --list | grep mysqld
    - require:
      - cmd: mariadb-install
  service.running:
    - name: mysqld
    - enable: True
    - reload: True
    - require:
      - cmd: mariadb-install
    - watch:
      - file: mariadb-config
