# 以部署php-fpm服务为例的playbook

### 创建文件目录
>     mkdir /soft
>     [root@server01 soft]# pwd && ls -l
>     /soft
>     total 37464
>     -rw-r--r-- 1 root root 19409040 Feb 24 21:28 php-7.3.2.tar.gz
>     -rw-r--r-- 1 root root  404 Feb 19 19:48 php-fpm.service
>     -rw-r--r-- 1 root root9 Feb 25 18:11 php_fpm_service.retry
>     -rw-r--r-- 1 root root 2261 Feb 25 18:09 php_fpm_service.yaml
>     -rw-r--r-- 1 root root   235569 Feb 24 21:28 redis-4.2.0.tgz
>     -rw-r--r-- 1 root root  234 Feb 25 18:23 www.conf.j2

>     [root@server01 soft]# cat www.conf.j2 
>     [www]
>     user = www
>     group = www
>     {{% if PORT  %}}
>     listen = 127.0.0.1:{{ PORT  }}
>     {{% else  %}}
>     listen = 127.0.0.1:9000
>     {{% endif  %}}
>     pm = dynamic
>     pm.max_children = 5
>     pm.start_servers = 2
>     pm.min_spare_servers = 1
>     pm.max_spare_servers = 3
>     [root@server01 soft]# 
    
    
### playbook例子:
    [root@server01 soft]# cat php_fpm_service.yaml
    	- hosts: servers ------------------------------------目标
      remote_user: root ---------------------------------远程用户
      vars:
    		PORT: 9001
      tasks: --------------------------------------------任务集
    	- name: php requrie pkg install -----------------task名称
    	  yum: ------------------------------------------yum模块 也可以使用 name={{ item }}
    		name: ---------------------------------------软件包名称 也可以使用 with_items:
    		  - libxml2
    		  - libxml2-devel
    		  - libcurl
    		  - libcurl-devel
    		  - libjpeg
    		  - libjpeg-devel
    		  - libpng
    		  - libpng-devel
    		  - freetype
    		  - freetype-devel
    		  - libicu-devel
    		  - gcc-c++
    		  - libxslt-devel
    		state: installed -----------------------------软件状态 installed 已安装状态
    	- name: useradd www ------------------------------任务名称
    	  shell: "[ -z $(grep www /etc/passwd) ] && useradd www -M -s /sbin/nologin || echo 'www is exist'" --- shell模块及 shell执行的命令
    	- name: copy tar to remote dir -------------------任务名称
		  copy: ------------------------------------------copy模块
			src: /soft/ ----------------------------------源文
			dest: /usr/local/src/ ------------------------ 目标
			owner: root ----------------------------------用户、组
			group: root
			mode: 644 ------------------------------------权限
    	- name: copy php-fpm.service
		  copy:
			src: /soft/php-fpm.service
			dest: /usr/lib/systemd/system/
			owner: root
			group: root
			mode: 644
    	- name: php dir ---------------------------------任务名称
		- name: php dir
		  shell: test -d /usr/local/php ------------------ 检测目录是否存在 --- 另一种方式 将 路径写到vars变量里 在when中通过 is exists is directory is file is link 等进行判断
		  ignore_errors: True ---------------------------- 忽略错误
		  register: php_dir ------------------------------ 注册此任务的结果
		- name: php install
		  shell: cd /usr/local/src/ && tar xf php-7.3.2.tar.gz && cd php-7.3.2 && ./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-config-file-scan-dir=/usr/local/php/etc/php.d --with-fpm-user=www --with-fpm-group=www --enable-fpm --enable-opcache --disable-fileinfo --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv --with-freetype-dir --with-jpeg-dir --with-png-dir -with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-exif --enable-sysvsem --enable-inline-optimization --with-curl=/usr/local --enable-mbregex --enable-mbstring --with-gd --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-intl --with-xsl --with-gettext --enable-zip --enable-soap --disable-debug && make -j4 && make install && cd /usr/local/php/etc/ && cp -a php-fpm.conf.default php-fpm.conf && cd php-fpm.d && cp -a www.conf.default www.conf
		  when: php_dir is failed ----------------------- 当结果为失败的时候执行 此task任务
	   	- name: template php-fpm.default
    	  template: --------------------------------------使用jinjia2模板 应用中 根据 vars 变量更新配置文件最好用 模板文件中表达式{%%} 变量 {{}}
			src: /soft/www.conf.j2
			dest: /usr/local/php/etc/php-fpm.d/www.conf
		  notify: php-fpm.service
      handlers:
		- name: php-fpm.service ----------------------------任务名称
		  systemd: -----------------------------------------systemd 服务管理模块
			name: php-fpm ----------------------------------服务名字
			enabled: yes -----------------------------------enabled
			state: restarted ---------------------------------状态已启动,已重启，服务如果是关闭的就开启服务

