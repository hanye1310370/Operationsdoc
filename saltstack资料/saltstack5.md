# 一、项目：
	1、系统初始化
	2、功能模块： 设置单独的目录 haproxy  nginx php mysqlo memecache
	3、业务模块： 根据业务类型划分 web服务 论坛 bbs

# 二、项目配置：
	1、salt环境配置
	开发 测试  预生产 生产

	环境初始化 dns配置 history记录时间 记录命令操作 内核参数优化 安装yum仓库
	安装 zabbix-agent 

	base 基础环境

	prod 生产环境
	[root@saltstack-node01 ~]# mkdir /srv/salt/{base,prod}
	[root@saltstack-node01 ~]# ll /srv/salt/
	总用量 0
	drwxr-xr-x 2 root root 6 1月   6 06:33 base
	drwxr-xr-x 2 root root 6 1月   6 06:33 prod

	file_roots:
	  base:
		- /srv/salt/base
	  prod:
		- /srv/salt/prod
	pillar_roots:
	  base:
		- /srv/pillar/base
	  prod:
		- /srv/pillar/prod

	[root@saltstack-node01 ~]# mkdir -p /srv/pillar/{base,prod}
	[root@saltstack-node01 ~]# ll /srv/pillar/
	总用量 0
	drwxr-xr-x 2 root root 6 1月   6 06:36 base
	drwxr-xr-x 2 root root 6 1月   6 06:36 prod

	2、zabbix配置：
	[root@saltstack-node01 /srv/salt/base/init]# cat /srv/salt/base/init/zabbix_agent.sls 
	zabbix-agent:
	  pkg.installed:
		- name: zabbix-agent
	  file.managed:
		- name: /etc/zabbix/zabbix_agentd.conf
		- source: salt://init/files/zabbix_agentd.conf
		- template: jinja
		- defaults:
		  Server: {{ pillar['Zabbix_Server'] }}------------------------定义jinjia模板 使用pillar数据 
		- require:
		  - pkg: zabbix-agent
	  service.running:
		- enable: True
		- watch:
		  - pkg: zabbix-agent
		  - file: zabbix-agent
	zabbix_agentd.conf.d:
	  file.directory:
		- name: /etc/zabbix/zabbix_agentd.d/
		- watch_in:
		  - service: zabbix-agent
		- require:
		  - pkg: zabbix-agent
		- file: zabbix-agent
	[root@saltstack-node01 /srv/salt/base/init]# grep '^S' /srv/salt/base/init/files/zabbix_agentd.conf 
	Server={{ Server }}-------------------------zabbix-agent配置文件引用jinjia
	ServerActive=127.0.0.1
	[root@saltstack-node01 /srv/salt/base/init]# cat /srv/pillar/base/top.sls 
	base:
	  '*':--------------------------------------pillar topfile 指定minion使用 pillar sls
		- zabbix.agent
	[root@saltstack-node01 /srv/salt/base/init]# cat /srv/pillar/base/zabbix/agent.sls 
	Zabbix_Server: 192.168.56.21----------------pillar sls
	[root@saltstack-node01 /srv/salt/base/init]#

	salt '*' state.sls init.zabbix_agent

# 三、以上zabbix的配置都在base环境下配置

	创建topfile 执行base环境高级状态
	[root@saltstack-node01 ~]# cd /srv/salt/base/
	[root@saltstack-node01 /srv/salt/base]# vim top
	[root@saltstack-node01 /srv/salt/base]# vim top.sls
	[root@saltstack-node01 /srv/salt/base]# tree
	.
	├── init
	│?? ├── audit.sls
	│?? ├── dns.sls
	│?? ├── epel.sls
	│?? ├── files
	│?? │?? ├── resolv.conf
	│?? │?? ├── sysctl.conf
	│?? │?? └── zabbix_agentd.conf
	│?? ├── history.sls
	│?? ├── init.sls
	│?? ├── sysctl.sls
	│?? └── zabbix_agent.sls
	└── top.sls

	2 directories, 11 files
	[root@saltstack-node01 /srv/salt/base]# salt '*' state.highstate


# 四、sls文件中 file模块 添加一个参数     - backup: minion  当配置文件发生更改 会备份更改前的文件 

		zabbix-agent:
		  pkg.installed:
			- name: zabbix-agent
		  file.managed:
			- name: /etc/zabbix/zabbix_agentd.conf
			- source: salt://init/files/zabbix_agentd.conf
			- template: jinja
			- backup: minion


	[root@saltstack-minion01 ~]# cd /var/cache/salt/minion/
	[root@saltstack-minion01 minion]# tree
	.
	├── accumulator
	├── extmods
	├── extrn_files
	│   └── base
	│       └── mirrors.aliyun.com
	│           └── epel
	│               └── epel-release-latest-7.noarch.rpm
	├── file_backup
	│   └── etc
	│       └── zabbix
	│           └── zabbix_agentd.conf_Fri_Jan_06_10:18:31_894242_20






