
# Saltstack-简介


	三大功能： 
			远程执行 
			配置管理（状态） 
			云管理
	四种运行方式：
			local  
			minion/master 
			c/s   
			syndic 代理   
			saltssh 
			
	典型案例：

## 一、安装配置master/minion

	http://repo.saltstack.com/#rhel

	# wget -O /etc/yum.repos.d/saltstack.repo https://repo.saltstack.com/yum/redhat/7.2/x86_64/saltstack-rhel7.repo
	# yum install https://repo.saltstack.com/yum/redhat/salt-repo-latest-2.el7.noarch.rpm

	# yum install salt-master salt-minion salt-ssh salt-cloud salt-api -y

	# systemctl restart salt-minion/salt-master

	# egrep '(#id|^[a-Z])' /etc/salt/minion
	master: 10.0.0.253------------------------------------minion配置文件配置master的ip
	#id:--------------------------------------------------id不配置 默认就是minion的主机名


	[root@saltstack-node01 ~]# salt-key-------------------salt-key命令 -a 添加指定预添加minion -A 添加所有的预添加minion
	Accepted Keys:
	saltstack-minion01
	Denied Keys:
	Unaccepted Keys:
	saltstack-node01
	Rejected Keys:
	[root@saltstack-node01 ~]# salt-key -a saltstack-minion01

	 
	[root@saltstack-node01 ~]# tree /etc/salt/pki/
	/etc/salt/pki/
	├── master
	│   ├── master.pem---------------------------------master的私钥
	│   ├── master.pub---------------------------------master的公钥
	│   ├── minions
	│   │   └── saltstack-minion01---------------------添加的minion的公钥
	│   ├── minions_autosign
	│   ├── minions_denied
	│   ├── minions_pre
	│   │   └── saltstack-node01-----------------------预备minion
	│   └── minions_rejected
	└── minion
		├── minion.pem
		└── minion.pub

	7 directories, 6 files

	[root@saltstack-minion01 ~]# tree /etc/salt/pki
	/etc/salt/pki
	├── master
	└── minion
		├── minion_master.pub--------------------------master的公钥
		├── minion.pem---------------------------------minion的私钥
		└── minion.pub---------------------------------minion的公钥

	2 directories, 3 files

## 二、salt远程执行：
	[root@saltstack-node01 ~]# salt '*' test.ping-------->‘*’ 通配符匹配目标  test.ping 是 test模块ping方法（这里的ping是通信方式）
	saltstack-minion01:
		True
	saltstack-node01:
		True

	[root@saltstack-node01 ~]# salt 'saltstack-minion01' cmd.run 'w' cmd模块 run方法  ‘w’ 远端要执行的命令
	saltstack-minion01:
		 11:10:33 up  1:00,  2 users,  load average: 0.00, 0.01, 0.05
		USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
		root     tty1                      10:13   55:05   0.59s  0.59s -bash
		root     pts/0    10.0.0.1         10:16   32:33   0.15s  0.15s -bash
	
## 三、状态模块 state  要写一个yaml的sls文件 放置的位置。
		YAML:
			1、缩进   （层级关系）
			2、冒号   （字典）
			3、短横线 （列表）
	sls文件放置位置：
	[root@saltstack-node01 ~]# egrep '(^ |^[a-Z])' /etc/salt/master
	file_roots:
	  base:
		- /srv/salt-----------------------------配置基础环境
	
	[root@saltstack-node01 ~]# systemctl restart salt-master.service
	[root@linux-node01 salt]# mkdir web
	[root@linux-node01 salt]# ls
	web
	[root@linux-node01 salt]# cd web/
	[root@linux-node01 web]# pwd
	/srv/salt/web
	
	[root@saltstack-node01 web]# pwd
	/srv/salt/web
	[root@saltstack-node01 web]# cat apache.sls ----------------写一个sls配置
	apache-install:
	  pkg.installed: ----pkg模块儿、installed安装方法
		- names:---------执行安装的软件名字
		  - httpd--------需要安装的软件列表
		  - httpd-devel

	apache-service:
	  service.running:---service服务模块儿、running运行方法
		- name: httpd----执行运行的服务名字
		- enable: True---服务启动状态
	[root@saltstack-node01 web]# 

	[root@saltstack-node01 web]# salt 'saltstack-minion01' state.sls web.apache-----------执行配置的状态文件

	[root@linux-node02 salt]# cd /var/cache/salt/--------执行状态后 master传送sls文件到minion端
	[root@saltstack-minion01 salt]# tree
	.
	└── minion
		├── accumulator
		├── extmods
		├── files
		│   └── base
		│       └── web
		│           └── apache.sls-----------------------------状态文件会发送到minion端 minion按照状态文件内容执行操作
		├── highstate.cache.p
		├── proc
		└── sls.p

	7 directories, 3 files
	[root@saltstack-minion01 salt]# 

	[root@saltstack-minion01 ~]# ps -ef|grep yum---------------minion端执行
	root      12183  12156 29 14:29 ?        00:00:02 /usr/bin/python /usr/bin/yum -y install httpd-devel
	root      12194   2859  0 14:29 pts/0    00:00:00 grep --color=auto yum


	[root@saltstack-node01 web]# salt 'saltstack-minion01' state.sls web.apache----server端从minion返回结果
	saltstack-minion01:
	----------
			  ID: apache-install
		Function: pkg.installed
			Name: httpd
		  Result: True
		 Comment: Package httpd is already installed
		 Started: 14:29:19.448226
		Duration: 2292.284 ms

	[root@saltstack-minion01 salt]# netstat -lntp|grep 80----------------minion端httpd服务启动
	tcp6       0      0 :::80                   :::*                    LISTEN      12383/httpd         
	[root@saltstack-minion01 salt]# 

## 四、高级状态配置： #state_top: top.sls

	高级状态的sls文件名字叫top.sls 位置放置再base环境根目录下
	# root of the base environment as defined in "File Server settings" below.

	[root@saltstack-node01 /srv/salt]# pwd
	/srv/salt
	[root@saltstack-node01 /srv/salt]# ls
	top.sls  web
	[root@saltstack-node01 /srv/salt]# cat top.sls 
	base:
	  'saltstack-node01':------------------------- minion id
		- web.apache ----------------------------- 自建的web模块下的apache状态sls文件
	  'saltstack-minion01':
		- web.apache
	
	[root@saltstack-node01 /srv/salt]# salt '*' state.highstate------------执行高级状态
	saltstack-minion01:
	----------
			  ID: apache-install
		Function: pkg.installed
			Name: httpd
		  Result: True
		 Comment: Package httpd is already installed
		 Started: 15:14:16.699162
		Duration: 5793.355 ms
		 Changes:  

	[root@saltstack-minion01 salt]# tree
	.
	└── minion
		├── accumulator
		├── extmods
		├── files
		│   └── base
		│       ├── top.sls------------------------------被指定执行高级状态的minion会接受 top.sls
		│       └── web
		│           └── apache.sls
		├── highstate.cache.p
		├── module_refresh
		├── pkg_refresh
		├── proc
		└── sls.p

	7 directories, 6 files

	[root@saltstack-node01 /srv/salt]# salt '*' state.highstate test=True(此参数加上可以测试执行)

## 五、salt于zeromq
	4505端口消息的发布监听端口
	4506端口接收返回消息的监听端口
	[root@saltstack-node01 /srv/salt]# netstat -lntp|grep python
	tcp        0      0 0.0.0.0:4505---->发消息监听端口            0.0.0.0:*               LISTEN      69809/python        
	tcp        0      0 0.0.0.0:4506---->接收返回消息监听端口      0.0.0.0:*               LISTEN      69815/python        
	[root@saltstack-node01 /srv/salt]# 

	[root@saltstack-node01 /srv/salt]# yum install python-setproctitle -y --显示进程名称

	[root@saltstack-node01 /srv/salt]# ps -ef|grep salt-master
	root      77669      1 48 15:52 ?        00:00:01 /usr/bin/python /usr/bin/salt-master ProcessManager
	root      77681  77669  0 15:52 ?        00:00:00 /usr/bin/python /usr/bin/salt-master MultiprocessingLoggingQueue
	root      77683  77669  0 15:52 ?        00:00:00 /usr/bin/python /usr/bin/salt-master ZeroMQPubServerChannel
	root      77684  77669  0 15:52 ?        00:00:00 /usr/bin/python /usr/bin/salt-master EventPublisher
	root      77687  77669 19 15:52 ?        00:00:00 /usr/bin/python /usr/bin/salt-master Maintenance
	root      77688  77669  7 15:52 ?        00:00:00 /usr/bin/python /usr/bin/salt-master ReqServer_ProcessManager
	root      77689  77688  3 15:52 ?        00:00:00 /usr/bin/python /usr/bin/salt-master MWorkerQueue
	root      77690  77688 30 15:52 ?        00:00:00 /usr/bin/python /usr/bin/salt-master MWorker-0
	root      77697  77688 30 15:52 ?        00:00:00 /usr/bin/python /usr/bin/salt-master MWorker-1
	root      77698  77688 27 15:52 ?        00:00:00 /usr/bin/python /usr/bin/salt-master MWorker-2
	root      77699  77688 25 15:52 ?        00:00:00 /usr/bin/python /usr/bin/salt-master MWorker-3
	root      77700  77688 23 15:52 ?        00:00:00 /usr/bin/python /usr/bin/salt-master MWorker-4
	root      77702  74888  0 15:52 pts/0    00:00:00 grep --color=auto salt-master
	[root@saltstack-node01 /srv/salt]# 

## 六、saltstack数据系统：

	一、saltstack数据类型grains ,minion
		
		静态数据  在当minion启动的时候收集的minion本地的相关信息

					   操作系统版本，内核版本，cpu，内存等
					   
		1、资产管理、信息查询。
		2、用于目标选择
		3、配置管理中使用
		
		[root@saltstack-node01 ~]# salt 'saltstack-minion01' grains.ls---------把所有grains里面的名称 列出来

		[root@saltstack-node01 ~]# salt 'saltstack-minion01' grains.items--------显示minion grains 名称key的值 

		[root@saltstack-node01 ~]# salt 'saltstack-minion01' grains.item fqdn_ip4
		saltstack-minion01:
			----------
			fqdn_ip4:
				- 10.0.0.252

		[root@saltstack-node01 ~]# salt -G 'os:CentOS' cmd.run 'echo hehe' ----用 -G参数 来定 目标
		saltstack-node01:
			hehe
		saltstack-minion01:
			hehe
		[root@saltstack-node01 ~]#

		1.1grains自定义：

			一、修改minion 配置文件 给minion定义 grains roles 。
			[root@saltstack-node01 ~]# salt 'saltstack-minion01' grains.item roles
			saltstack-minion01:
				----------
				roles:---------------------一开始没有roles
			[root@saltstack-node01 ~]#
			[root@saltstack-minion01 ~]# egrep '(^g|^ )' /etc/salt/minion
			grains:
			  roles: apache---------------配置roles
			[root@saltstack-minion01 ~]# 

			[root@saltstack-node01 ~]# salt -G 'roles:apache' cmd.run 'egrep "(^g|^ )" /etc/salt/minion'
			saltstack-minion01:
				grains:
				  roles: apache
			[root@saltstack-node01 ~]#

			二、在minion端 /etc/salt/ 下 写一个 名字 grains的配置文件  格式也是yaml格式 比如：
				[root@saltstack-minion01 salt]# cat /etc/salt/grains 工作中使用此文件定义grains 不必在配置文件中定义
				cloud: openstack
				[root@saltstack-minion01 salt]#
				[root@saltstack-node01 ~]# salt '*' grains.item cloud
				saltstack-minion01:
					  ----------
					  cloud:
						  openstack
					saltstack-node01:
					  ----------
						  cloud:
				
				[root@saltstack-node01 ~]# salt '*' saltutil.sync_grains--------------使用此命令可以刷新grains 就不用minion重启了
				saltstack-node01:
				saltstack-minion01:
		
			三、top.sls 高级状态调用grains
			[root@saltstack-node01 ~]# cat /srv/salt/top.sls 
			base:
			  'saltstack-node01':
				- web.apache
			  'roles:apache':------------- grains指定目标方式
				- match: grain-------------匹配 grains数据
				- web.apache ------------- 执行模块和方法

			[root@saltstack-node01 ~]# salt '*' state.highstate  

	二、开发一个grains：
		 python脚本 返回一个字典

		[root@saltstack-node01 ~]# cd /srv/salt/
		[root@saltstack-node01 /srv/salt]# mkdir _grains
		[root@saltstack-node01 /srv/salt]# cd _grains/
		[root@saltstack-node01 /srv/salt/_grains]# vim my_grains.py

		[root@saltstack-node01 /srv/salt/_grains]# cat my_grains.py 
		#!/usr/bin/env python
		#_*_ coding: utf-8 _*_

		def my_grains():
			#初始化一个grains字典
			grains = {}
			#设置字典中的key-value
			grains['iaas'] = 'openstack'
			grains['edu'] = 'oldboyedu'
			#返回这个字典
			return grains
		[root@saltstack-node01 /srv/salt/_grains]# 

		同步到minion
		[root@linux-node01 _grains]# salt '*' saltutil.sync_grains
		linux-node02:
			- grains.my_grains
		linux-node01:
			- grains.my_grains

		[root@saltstack-minion01 salt]# cd /var/cache/salt/
		[root@saltstack-minion01 salt]# tree
		.
		└── minion
			├── accumulator
			├── extmods
			│   └── grains
			│       ├── my_grains.py------------ 同步到minion的grains py脚本）
			│       └── my_grains.pyc
			├── files
			│   └── base
			│       ├── _grains
			│       │   └── my_grains.py
			│       ├── top.sls
			│       └── web
			│           └── apache.sls
			├── highstate.cache.p
			├── module_refresh
			├── pkg_refresh
			├── proc
			└── sls.p

		9 directories, 9 files
		[root@saltstack-minion01 salt]# 
		[root@saltstack-node01 /srv/salt/_grains]# salt '*' saltutil.sync_grains
		saltstack-node01:
			- grains.my_grains
		saltstack-minion01:
			- grains.my_grains
		[root@saltstack-node01 /srv/salt/_grains]# salt '*' grains.item iaas
		saltstack-minion01:
			----------
			iaas:
				openstack
		saltstack-node01:
			----------
			iaas:
				openstack
		[root@saltstack-node01 /srv/salt/_grains]# 

	三、grains优先级：
		1、系统自带 grains items
		2、grains文件写的-----/etc/salt/grains文件
		3、minion配置文件写的-----------配置文件
		4、自己写的	就是/srv/salt/下创建_grains目录 并在此目录下写自己的grains文件（py脚本）

## 七、pillar数据类型：

	一、pillar 数据动态的，给特定的minion指定特定的数据【类似top.sls的作用一样】
		只有指定的minion能看到自己的数据。用于存储加密数据、定义变量。
		
		[root@saltstack-node01 ~]# salt '*' pillar.items ------------ 查看pillar数据类型
		saltstack-minion01:
			----------
		saltstack-node01:
			----------
		[root@saltstack-node01 ~]# 

		[root@saltstack-node01 ~]# egrep '^p' /etc/salt/master
		pillar_opts: True---------------------------------原本是false 改为true就可以显示 已有的pillar.items
		[root@saltstack-node01 ~]#

		[root@saltstack-node01 ~]# salt '*' pillar.items
		saltstack-minion01:
			----------
			master:
				----------
				__role:
					master
				archive_jobs:
					False

		.....................

	二、定义pillar的数据：pillar数据需要创建sls文件来定义
	
		[root@saltstack-node01 ~]# vim /etc/salt/master
		[root@saltstack-node01 ~]# egrep '(^[a-z]|^ )' /etc/salt/master
		file_roots:
		  base:
			- /srv/salt
		pillar_roots:-------------pillar的sls文件目录 top.sls 
		  base:
			- /srv/pillar
		[root@saltstack-node01 ~]# 
		[root@saltstack-node01 ~]# tree /srv/
		/srv/
		├── pillar
		└── salt
			├── _grains
			│   └── my_grains.py
			├── top.sls
			└── web
				└── apache.sls

		4 directories, 3 files
		[root@saltstack-node01 ~]#

		[root@saltstack-node01 /srv]# ls
		pillar  salt
		[root@saltstack-node01 /srv]# cd pillar/
		[root@saltstack-node01 /srv/pillar]# mkdir web
		[root@saltstack-node01 /srv/pillar]# cd web
		
		[root@saltstack-node01 /srv/pillar/web]# vim apache.sls
		
		[root@saltstack-node01 /srv/pillar/web]# cat apache.sls 
		{% if grains['os'] == 'CentOS' %}
		apache: httpd
		{% elif grains['os'] == 'Ubuntu' %}
		apache: apache2
		{% endif %}

		[root@saltstack-node01 /srv]# tree
		.
		├── pillar
		│   ├── top.sls
		│   └── web
		│       └── apache.sls
		└── salt
			├── _grains
			│   └── my_grains.py
			├── top.sls
			└── web
				└── apache.sls

		5 directories, 5 files
		[root@saltstack-node01 /srv]#

		[root@saltstack-node01 /srv]# cat pillar/web/apache.sls 
		{% if grains['os'] == 'CentOS' %}
		apache: httpd
		{% elif grains['os'] == 'Debian' %}
		apache: apache2
		{% endif %}
		[root@saltstack-node01 /srv]# 
		
	三、写pillar的top.sls pillar需要使用topfile指定主机使用自定义的pillar数据
		

		[root@saltstack-node01 /srv]# salt '*' pillar.items apache
		saltstack-node01:
			----------
			apache:
		saltstack-minion01:
			----------
			apache:
		[root@saltstack-node01 /srv]# salt '*' saltutil.refresh_pillar-----刷新
		saltstack-minion01:
			True
		saltstack-node01:
			True
		[root@saltstack-node01 /srv]# salt '*' pillar.items apache
		saltstack-minion01:
			----------
			apache:
				httpd---------------- topfile 里只指定了 saltstack-minion01
		saltstack-node01:
			----------
			apache:
		[root@saltstack-node01 /srv]#
		
        定义层级
		[root@saltstack-node01 /srv/pillar/web]# cat apache.sls 
		hehe:
		  {% if grains['os'] == 'CentOS' %}
		  apache: httpd
		  {% elif grains['os'] == 'Debian' %}
		  apache: apache2
		  {% endif %}
		[root@saltstack-node01 /srv/pillar/web]# 

		[root@saltstack-node01 /srv/pillar/web]# salt '*' pillar.items hehe
		saltstack-node01:
			----------
			hehe:
		saltstack-minion01:
			----------
			hehe:--------------------------pillar里可以定层级
				----------
				apache:
					httpd
		[root@saltstack-node01 /srv/pillar/web]# 

	四、pillar目标指定 参数 -I

	[root@saltstack-node01 /srv/pillar/web]# salt -I 'apache:httpd' test.ping
	saltstack-minion01:
		True
	[root@saltstack-node01 /srv/pillar/web]# 

	grain和pillar对比：
		 
		   类型       数据采集方式         应用场景                         定义位置

	grains 静态的     minion启动时候       数据查询 目标选择 配置管理       minion

	pillar 动态的     master自定义         目标选择 配置管理 敏感数据       master







