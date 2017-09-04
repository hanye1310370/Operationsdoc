#saltstack 配置haproxy

#1、安装一遍haproxy
	wget http://www.haproxy.org/download/1.7/src/haproxy-1.7.5.tar.gz
	cp haproxy-1.7.5.tar.gz /usr/local/src
	cd /usr/local/src
	tar xf haproxy-1.7.5.tar.gz
	cd haproxy-1.7.5
	make TARGET=linux2628 PREFIX=/usr/local/haproxy-1.7.5
	make install PREFIX=/usr/local/haproxy-1.7.5 
	ln -s /usr/local/haproxy-1.7.5 /usr/local/haproxy
	

	[root@saltstack-node01 /srv/salt/prod]# ll
	总用量 0
	drwxr-xr-x 3 root root 44 1月   6 14:07 cluster
	drwxr-xr-x 8 root root 86 1月   6 13:04 modules
	[root@saltstack-node01 /srv/salt/prod]# 
	
	[root@saltstack-node01 /srv/salt/prod]# tree modules/
	modules/
	├── haproxy
	│   ├── files
	│   │   ├── haproxy-1.6.9.tar.gz
	│   │   └── haproxy.init
	│   └── install.sls
	├── keepalived
	├── memecached
	├── nginx
	├── php
	└── pkg
	    └── make.sls
	[root@saltstack-node01 /srv/salt/prod]# tree
	.
	├── cluster
	│   ├── files
	│   │   └── haproxy-outside.cfg
	│   └── haproxy-outside.sls
	└── modules
	    ├── haproxy
	    │   ├── files
	    │   │   ├── haproxy-1.6.9.tar.gz
	    │   │   └── haproxy.init
	    │   └── install.sls
	    ├── keepalived
	    ├── memecached
	    ├── nginx
	    ├── php
	    └── pkg
	        └── make.sls
			
			
	[root@saltstack-node01 /srv/salt/prod]# cat modules/pkg/make.sls 
	make-pkg:
	  pkg.installed:
	    - pkgs:
	      - gcc
	      - gcc-c++
	      - glibc
	      - make
	      - autoconf
	      - openssl
	      - openssl-devel
	      - pcre
	
	
	[root@saltstack-node01 /srv/salt/prod]# cat modules/haproxy/install.sls 
	include:
	  - modules.pkg.make
	haproxy-install:
	  file.managed:
	    - name: /usr/local/src/haproxy-1.6.9.tar.gz
	    - source: salt://modules/haproxy/files/haproxy-1.6.9.tar.gz
	    - mode: 755
	    - user: root
	    - group: root
	  cmd.run:
	    - name: cd /usr/local/src && tar xf haproxy-1.6.9.tar.gz && cd haproxy-1.6.9 && make TARGET=linux2628 PREFIX=/usr/local/haproxy-1.6.9 && make install PREFIX=/usr/local/haproxy-1.6.9 && ln -s /usr/local/haproxy-1.6.9 /usr/local/haproxy
	    - unless: test -L /usr/local/haproxy ---------------------- 如果为真 证明安装过了 不执行安装
	    - require:
	      - pkg: make-pkg
	      - file: haproxy-install
	
	haproxy-init:
	  file.managed:
	    - name: /etc/init.d/haproxy
	    - source: salt://modules/haproxy/files/haproxy.init
	    - mode: 755
	    - user: root
	    - group: root
	    - require_in:
	      - file: haproxy-install
	  cmd.run:
	    - name: chkconfig --add haproxy
	    - unless: chkconfig --list | grep haproxy
	
	net.ipv4.ip_nonlocal_bind:
	  sysctl.present:
	    - value: 1
	
	/etc/haproxy:
	  file.directory:
	    - user: root
	    - group: root
	    - mode: 755
	
	[root@saltstack-node01 /srv/salt/prod]# cat cluster/haproxy-outside.sls 
	include:
	  - modules.haproxy.install
	
	haproxy-service:
	  file.managed:
	    - name: /etc/haproxy/haproxy.cfg
	    - source: salt://cluster/files/haproxy-outside.cfg
	    - user: root
	    - group: root
	    - mode: 644
	  service.running:
	    - name: haproxy
	    - enable: True
	    - reload: True
	    - require:
	      - cmd: haproxy-install
	    - watch:
	      - file: haproxy-service
	
	[root@saltstack-node01 /srv/salt/prod]# cat /srv/salt/base/top.sls 
	base:
	  '*':
	    - init.init
	prod:
	  '*':
	    - cluster.haproxy-outside
	[root@saltstack-node01 /srv/salt/prod]# 



# saltstack keepalived 实战

	[root@linux-node01 keeplived]# pwd
	/srv/salt/prod/modules/keeplived
	[root@linux-node01 keeplived]# tree
	.
	├── files
	│   ├── keepalived-1.2.17.tar.gz
	│   ├── keepalived.init
	│   └── keepalived.sysconfig
	└── install.sls

	1 directory, 4 files
	
	[root@linux-node01 keeplived]# 
	[root@linux-node01 keeplived]# pwd
	/srv/salt/prod/modules/keeplived
	[root@linux-node01 keeplived]# cat install.sls 
	{% set keepalived_tar = 'keepalived-1.2.17.tar.gz' %} ------------- sls里定义变量引用方法
	{% set keepalived_source  = 'salt://modules/keeplived/files/keepalived-1.2.17.tar.gz' %}
	keepalived-install:
	  file.managed:
		- name: /usr/local/src/{{ keepalived_tar }} ------------------- 引用变量
		- source: {{ keepalived_source }} ------------------------------应用变量
		- mode: 755
		- user: root
		- group: root
	  cmd.run:
		- name: cd /usr/local/src && tar zxf {{ keepalived_tar }} && cd keepalived-1.2.17 && ./configure --prefix=/usr/local/keepalived --disable-fwmark && make && make install
		- unless: test -d /usr/local/keepalived
		- require:
		  - file: keepalived-install

	/etc/sysconfig/keepalived:
	  file.managed:
		- source: salt://modules/keeplived/files/keepalived.sysconfig
		- mode: 644
		- user: root
		- group: root

	/etc/init.d/keepalived:
	  file.managed:
		- source: salt://modules/keeplived/files/keepalived.init
		- mode: 755
		- user: root
		- group: root

	keepalived-init:
	  cmd.run:
		- name: chkconfig --add keepalived
		- unless: chkconfig --list | grep keepalived
		- require:
		  - file: /etc/init.d/keepalived

	/etc/keepalived:
	  file.directory:
		- user: root
		- group: root
	[root@linux-node01 keeplived]# 
	
	[root@linux-node01 cluster]# pwd
	/srv/salt/prod/cluster
	[root@linux-node01 cluster]# ls
	files  haproxy-outside-keepalived.sls  haproxy-outside.sls
	[root@linux-node01 cluster]# tree
	.
	├── files
	│   ├── haproxy-outside.cfg
	│   └── haproxy-outside-keepalived.conf
	├── haproxy-outside-keepalived.sls
	└── haproxy-outside.sls
	
	1 directory, 4 files
	
	[root@linux-node01 cluster]# cat haproxy-outside-keepalived.sls 
	include:
	  - modules.keeplived.install
	keepalived-server:
	  file.managed:
	    - name: /etc/keepalived/keepalived.conf
	    - source: salt://cluster/files/haproxy-outside-keepalived.conf
	    - mode: 644
	    - user: root
	    - group: root
	    - template: jinja
	    {% if grains['fqdn'] == 'linux-node01' %}
	    - ROUTEID: haproxy_ha
	    - STATEID: MASTER
	    - PRIORITYID: 150
	    {% elif grains['fqdn'] == 'linux-node02' %}
	    - ROUTEID: haproxy_ha
	    - STATEID: BACKUP
	    - PRIORITYID: 100
	    {% endif %}
	  service.running:
	    - name: keepalived
	    - enable: True
	    - watch:
	      - file: keepalived-server
	[root@linux-node01 cluster]# 
	
	[root@linux-node01 cluster]# cat files/haproxy-outside-keepalived.conf 
	! Configuration File for keepalived
	global_defs {
	   notification_email {
	     saltstack@example.com
	   }
	   notification_email_from keepalived@example.com
	   smtp_server 127.0.0.1
	   smtp_connect_timeout 30
	   router_id {{ROUTEID}}
	}
	
	vrrp_instance haproxy_ha {
	state {{STATEID}}
	interface eth0
	    virtual_router_id 36
	priority {{PRIORITYID}}
	    advert_int 1
	authentication {
	auth_type PASS
	        auth_pass 1111
	    }
	    virtual_ipaddress {
	       10.0.0.13
	    }
	}
	
	[root@linux-node01 cluster]# 
	
	[root@linux-node01 bbs]# salt '*' saltutil.running ------------列出所有执行的job 获取jobid
	linux-node01:
	linux-node02:
	
	[root@linux-node01 bbs]# 
	salt '*' saltutil.kill_job <job id> 根据jobid 杀掉进程









