
# 一、jinjia模板: python的模板语言
    两种分隔符：
	{%    %} 表达式
	{{    }}  变量

	使用jinjia模板定义为一部分内容（变量|表达式）模式



		 Changes:   
				  ----------
				  diff:
					  --- 
					  +++ 
					  @@ -39,7 +39,7 @@
					   # prevent Apache from glomming onto all bound IP addresses.
					   #
					   #Listen 12.34.56.78:80
					  -Listen 80
					  +Listen 81
					   
					   #
					   # Dynamic Shared Object (DSO) Support
	----------

	3步：
	   1、告诉file模块 要使用jinjia -------------修改sls文件
			  - template: jinja
	   2、你要列出变量参数列表-------------------修改sls
		   - defaults:
			 PORT: 88
	   3、模板的引用------------------------------修改配置文件httpd.conf
		  {{ PORT }}
		  
	  
		 重新执行：
		      Changes:   
              ----------
              diff:
                  --- 
                  +++ 
                  @@ -39,7 +39,7 @@
                   # prevent Apache from glomming onto all bound IP addresses.
                   #
                   #Listen 12.34.56.78:80
                  -Listen 81
                  +Listen 88
                   
                   #
                   # Dynamic Shared Object (DSO) Support
				   
				   

# 二、模板里面支持 salt  grians pillar 进行赋值
	# vim /srv/salt/lamp/files/httpd.conf
	Listen {{ grains['fqdn_ip4'][0] }}:{{ PORT }}-------------------引用jinja

		 Changes:   
				  ----------
				  diff:
					  --- 
					  +++ 
					  @@ -39,7 +39,7 @@
					   # prevent Apache from glomming onto all bound IP addresses.
					   #
					   #Listen 12.34.56.78:80
					  -Listen ['10.0.0.252']:88
					  +Listen 10.0.0.252:88
					   
					   #
					   # Dynamic Shared Object (DSO) Support

# 三、salt远程执行模块
	[root@saltstack-node01 /srv/salt/lamp]# salt '*' network.hw_addr eth0
	saltstack-minion01:
		00:0c:29:ad:39:c5
	saltstack-node01:
		00:0c:29:4b:a0:aa

	# vim /srv/salt/lamp/files/httpd.conf
	Listen {{ grains['fqdn_ip4'][0] }}:{{ PORT }}
	#{{ salt['network.hw_addr']('eth0') }}--------------------------使用salt的远程执行的功能

		 Changes:   
				  ----------
				  diff:
					  --- 
					  +++ 
					  @@ -40,7 +40,7 @@
					   #
					   #Listen 12.34.56.78:80
					   Listen 10.0.0.252:88
					  -
					  +#00:0c:29:ad:39:c5

					  
				  
# 四、pillar使用：

	{{ pillar['apache'] }}

		 Changes:   
				  ----------
				  diff:
					  --- 
					  +++ 
					  @@ -41,6 +41,7 @@
					   #Listen 12.34.56.78:80
					   Listen 10.0.0.252:88
					   #00:0c:29:ad:39:c5
					  +#httpd
					   #
					   # Dynamic Shared Object (DSO) Support
					   #
	----------

# 五、写到sls文件中：
	apache-config:
	  file.managed:
		- name: /etc/httpd/conf/httpd.conf
		- source: salt://lamp/files/httpd.conf
		- user: root
		- group: root
		- mode: 644
		- template: jinja
		- defaults:
		  IPADDR: {{ grains['fqdn_ip4'][0] }}
		  PORT: 86
	------------------------------------------------------------
     Changes:   
              ----------
              diff:
                  --- 
                  +++ 
                  @@ -39,7 +39,7 @@
                   # prevent Apache from glomming onto all bound IP addresses.
                   #
                   #Listen 12.34.56.78:80
                  -Listen 10.0.0.252:88
                  +Listen 10.0.0.252:86
                   #00:0c:29:ad:39:c5
                   #httpd
                   #


