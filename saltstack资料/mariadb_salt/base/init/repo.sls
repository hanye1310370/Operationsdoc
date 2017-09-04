yum_repo:
  pkg.installed:
    - sources:       
        - zabbix: https://mirrors.aliyun.com/zabbix/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm
    - unless: test -f /etc/yum.repos.d/zabbix.repo
  cmd.run:
    - names:
      - wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo 
      - yum install epel-release
      - yum makecache
