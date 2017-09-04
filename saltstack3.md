# saltstack配置管理之状态管理

##	salt state sls描述文件 YAML

# 一、名称ID声明 id要唯一
	apache-install:
	  pkg.installed:
		- names:
		  - httpd
		  - httpd-devel

	apache-service:----------ID声明
	  service.running:-------模块.方法
		- name: httpd
		- enable: True
	php:---------------------pkg.installed不指定 name的话  直接装 id声明为名字的包
	  pkg.installed
	  
# 二、规划一个LAMP架构
  
	  1、pkg.installed 安装 
			pkgs: 安装多个包
			names: 同上
		 pkg.latest 确保最新版本
		 pkg.remove 删除
		 pkg.purge 卸载并删除配置文件
	  2、file.managed
	  3、service.running
	  
	  LAMP例子：
	  lamp-pkg:
	    pkg.installed:
		  - pkgs:
		    - httpd
			- httpd-devel
			- php
			- php-cli
			- php-mbstring
			- mariadb
			- mariadb-server
			- mariadb-devel
	  apache-config:
		file.managed:
		  - name: /etc/my.cnf
		  - source: salt://lamp/files/my.cnf salt ------------------//当前环境的根目录 /srv/salt/
		  - user: root
		  - group: root
		  - mode: 644
	  php-config:
	    file.managed:
		  - name: /etc/php.ini
		  - source: salt://lamp/files/php.ini
		  - user: root
		  - group: root
		  - mode: 644
	  mysql-config:
	    file.managed:
		  - name: /etc/my.cnf
		  - source: salt://lamp/files/my.cnf
		  - user: root
		  - group: root
		  - mode: 644
		  - user: root
		  - group: root
		  - mode: 644
	  apache-service:
		service.running:
		  - name: httpd
		  - enable: True
		  - reload: True
		  
	  mysql-service:
		service.running:
		  - name: mariadb
		  - enable: True
		  - reload: True
  
# 三、状态间关系：

		我依赖谁
			- require:
			  - pkg: lamp-pkg
			  - file: mysql-config
		我被谁依赖
			- require_in:
			  - service: mysql-service
		我监控谁
		    - reload: True -------------- 如果不加这一行就会重启而不是重载
			- watch:
			  - file: apache-config ------------ 文件发生变化就服务重载

		我被谁监控
			- watch_in:
			  - file: mysql-service
			  
		我引用谁
		include:
		  - lamp.pkg
		[root@saltstack-node01 /srv/salt/lamp]# cat lamp.sls
		include:
		  - lamp.pkg
		  - lamp.config
		  - lamp.service

		我扩展谁 
		
		
		[root@saltstack-node01 /srv/salt/lamp]# cat lamp.sls
		lamp-pkg:
		  pkg.installed:
			- pkgs:
			  - httpd
			  - php
			  - mariadb
			  - mariadb-server
			  - php-mysql
			  - php-cli
			  - php-mbstring

		apache-config:
		  file.managed:
			- name: /etc/httpd/conf/httpd.conf
			- source: salt://lamp/files/httpd.conf
			- user: root
			- group: root
			- mode: 644

		mysql-config:
		  file.managed:
			- name: /etc/my.cnf
			- source: salt://lamp/files/my.cnf
			- user: root
			- group: root
			- mode: 644
			- require_in:
			  - service: mysql-service

		php-config:
		  file.managed:
			- name: /etc/php.ini
			- source: salt://lamp/files/php.ini
			- user: root
			- group: root
			- mode: 644

		apache-service:
		  service.running:
			- name: httpd
			- enable: True
			- reload: True
			- require:
			  - pkg: lamp-pkg
			  - file: apache-config
			- watch:
			  - file: apache-config
		mysql-service:
		  service.running:
			- name: mariadb
			- enable: True
			- reload: True
			- require:
			  - pkg: lamp-pkg
			  - file: mysql-config
			- watch:
			  - file: mysql-config

	修改方式：
		[root@saltstack-node01 /srv/salt/lamp]# cat lamp.sls
		apache-server:
		  pkg.installed:
			- pkgs:
			  - httpd
		  file.managed:
			- name: /etc/httpd/conf/httpd.conf
			- source: salt://lamp/files/httpd.conf
			- user: root
			- group: root
			- mode: 644
		  service.running:
			- name: httpd
			- enable: True
			- reload: True

		mysql-server:
		  pkg.installed:
			- pkgs:
			  - mariadb
			  - mariadb-server
		  file.managed:
			- name: /etc/my.cnf
			- source: salt://lamp/files/my.cnf
			- user: root
			- group: root
			- mode: 644
		  service.running:
			- name: mariadb
			- enable: True
			- reload: True

		php-config:
		  pkg.installed:
			- pkgs:
			  - php-mysql
			  - php-cli
			  - php-mbstring
		  file.managed:
			- name: /etc/php.ini
			- source: salt://lamp/files/php.ini
			- user: root
			- group: root
			- mode: 644

# 四、每个状态模块分开写：
	[root@linux-node01 lamp]# pwd
	/srv/salt/lamp
	[root@linux-node01 lamp]# tree
	.
	├── config.sls
	├── files
	│   ├── httpd.conf
	│   ├── my.cnf
	│   └── php.ini
	├── init.sls
	├── pkg.sls
	└── service.sls

	1、[root@saltstack-node01 /srv/salt/lamp]# cat lamp.sls
		include:----------------------- ---我引用谁
		  - lamp.pkg
		  - lamp.config
		  - lamp.service
	  
	2、[root@saltstack-node01 /srv/salt/lamp]# cat config.sls 
		apache-config:
		  file.managed:
			- name: /etc/httpd/conf/httpd.conf
			- source: salt://lamp/files/httpd.conf
			- user: root
			- group: root
			- mode: 644

		mysql-config:
		  file.managed:
			- name: /etc/my.cnf
			- source: salt://lamp/files/my.cnf
			- user: root
			- group: root
			- mode: 644
			- require_in:-------------------我被谁依赖
			  - service: mysql-service

		php-config:
		  file.managed:
			- name: /etc/php.ini
			- source: salt://lamp/files/php.ini
			- user: root
			- group: root
			- mode: 644

	3、[root@saltstack-node01 /srv/salt/lamp]# cat service.sls 
		apache-service:
		  service.running:
			- name: httpd
			- enable: True
			- reload: True
			- require:
			  - pkg: lamp-pkg
			  - file: apache-config
			- watch:--------------------------- 我监控谁
			  - file: apache-config
		mysql-service:
		  service.running:
			- name: mariadb
			- enable: True
			- reload: True
			- require:------------------------- 我依赖谁
			  - pkg: lamp-pkg
			  - file: mysql-config
			- watch:--------------------------- 我监控谁
			  - file: mysql-config
			  
	4、[root@saltstack-node01 /srv/salt/lamp]# cat pkg.sls 
		lamp-pkg:
		  pkg.installed:
			- pkgs:
			  - httpd
			  - php
			  - mariadb
			  - mariadb-server
			  - php-mysql
			  - php-cli
			  - php-mbstring

# 五、如何编写sls技巧：

	1、安状态分类 如果单独使用，很清晰
	2、按服务分类 可以被其他的sls include引用。

