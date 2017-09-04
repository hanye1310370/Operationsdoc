# saltstack 实战案例 job管理和runner

# salt syndic

	[root@saltstack-node01 /var/cache/salt/master/jobs]# vim /etc/salt/master
	[root@saltstack-node01 /var/cache/salt/master/jobs]# yum install -y salt-syndic
	
	重点 ：Syndic的file_roots和pillar_roots必须和master保持一致


# salt-api

###	一、做证书服务：

	[root@saltstack-node01 /etc/pki/tls]# pwd
	/etc/pki/tls
	[root@saltstack-node01 /etc/pki/tls]# make testcert
	设置密码 一路回车
	[root@saltstack-node01 /etc/pki/tls/private]# pwd
	/etc/pki/tls/private
	[root@saltstack-node01 /etc/pki/tls/private]# openssl rsa -in localhost.key -out salt_nopass.key
	
###	二、安装pip
	#yum install python-pip
	#pip install CherryPy
	# vim master
	 default_include: master.d/*.conf
	
	[root@saltstack-node01 /etc/salt/master.d]# ls
	api.conf  eauth.conf
	
	[root@saltstack-node01 /etc/salt/master.d]# cat api.conf 
	rest_cherrypy:
	  host: 10.0.0.253
	  port: 8000
	  ssl_crt: /etc/pki/tls/certs/localhost.crt
	  ssl_key: /etc/pki/tls/private/salt_nopass.key
	[root@saltstack-node01 /etc/salt/master.d]# cat eauth.conf 
	external_auth:
	  pam:
	    saltapi:
	      - .*
	      - '@wheel'
	      - '@runner'
	[root@saltstack-node01 /etc/salt/master.d]# 
	
###	三、创建api账号及设置密码

	#useradd -M -s /sbin/nologin saltapi
	#echo saltapi|passwd saltapi --stdin
	
	# systemctl restart salt-master
	# systemctl restart salt-api
	
	[root@linux-node01 master.d]# curl -k https://10.0.0.11:8000/login \
	-H 'Accept: application/x-yaml' \
	-d username='saltapi' \
	-d password='saltapi' \
	-d eauth='pam'
	return:
	- eauth: pam
	  expire: 1497019450.557997
	  perms:
	  - .*
	  - '@wheel'
	  - '@runner'
	  start: 1496976250.557995
	  token: f4e8a5c489aa97dce25578c7da3f807a1db128d0
	  user: saltapi
	
	
###	四、获取api token

	[root@linux-node01 master.d]# curl -k https://10.0.0.11:8000/login \
	-H 'Accept: application/x-yaml' \
	-d username='saltapi' \
	-d password='saltapi' \
	-d eauth='pam'
	return:
	- eauth: pam
	  expire: 1497019450.557997
	  perms:
	  - .*
	  - '@wheel'
	  - '@runner'
	  start: 1496976250.557995
	  token: f4e8a5c489aa97dce25578c7da3f807a1db128d0
	  user: saltapi
	
###	五、使用token

	# curl -k https://10.0.0.11:8000/minions/linux-node01 \
	-H 'Accept: application/x-yaml' \
	-H 'X-Auth-Token: f4e8a5c489aa97dce25578c7da3f807a1db128d0'
	
	[root@linux-node01 master.d]# curl -k https://10.0.0.11:8000 \
	-H 'Accept: application/x-yaml' \
	-H 'X-Auth-Token: f4e8a5c489aa97dce25578c7da3f807a1db128d0' \
	-d client='runner' \
	-d fun='manage.status'
	return:
	- down: []
	  up:
	  - linux-node02
	  - linux-node01
	
	
	[root@linux-node01 master.d]# curl -k https://10.0.0.11:8000 \
	> -H 'Accept: application/x-yaml' \
	> -H 'X-Auth-Token: f4e8a5c489aa97dce25578c7da3f807a1db128d0' \
	> -d client='local' \
	> -d tgt='*' \
	> -d fun='test.ping'
	return:
	- linux-node01: true
	  linux-node02: true




