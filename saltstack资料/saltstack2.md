## 深入学习saltstack远程执行：
## salt '*' cmd.run 'w'
## 命令：salt
## 目标：'*' 目标支持正则 通配符 grains 和pillar目标
## 模块：cmd.run 自带模块 模块下有多方法  自己写模块
## 返回：‘w’ 执行后结果返回，returnners模块

# 目标：targeting
	1、和minion id有关的
	   minion id  主机名或者minion配置文件配置的id
	   通配符：‘*’  'saltstack*' 'saltstack*01' ‘saltstack[1|2]’ 
	2、列表
	   # salt -L 'saltstack-node01,saltstack-minion01' test.ping
	3、正则
	   # salt -E 'saltstack-(node01|minion01)' test.ping
       # salt -E 'saltstack-(.*)01' test.ping
	   # salt -E 'saltstack-(node01|(.*)01)' test.ping
	所有匹配的方式都可以用到top file里面来指定
	
	主机名设计方案：
	   1、ip地址
	   2、根据业务来进行设置
	      redis-node1-redis04-idc04-soa.example.com
		  redis-node1 redis第一个节点
		  redis04 机房
		  soa 业务线
	4、IP地址、子网
	   # salt -S 10.0.0.0/24 test.ping
	   # salt -S 10.0.0.252 test.ping
	   
	5、grain 和 pillar
	   -G
	   -I
	6、nodegroups
	   [root@saltstack-node01 /srv/pillar/web]# egrep '(^[a-Z]|^ )' /etc/salt/master
       file_roots:
       base:
       - /srv/salt
       pillar_roots:
       base:
       - /srv/pillar
       nodegroups:
         web: 'L@saltstack-node01,saltstack-minion01'
       [root@saltstack-node01 /srv/pillar/web]# systemctl restart salt-master.service 
       [root@saltstack-node01 /srv/pillar/web]# salt -N web test.ping
       saltstack-node01:
       True
       saltstack-minion01:
       True
    7、混合匹配
	    -C 
    8、批处理：百分比 可以 先百分之多少minion执行 然后剩下的百分之多少再执行
	    -b
		[root@saltstack-node01 /srv/pillar/web]# salt '*' -b 50 test.ping

        Executing run on ['saltstack-node01', 'saltstack-minion01']

        jid:
            20170105195417028456
        retcode:
            0
        saltstack-minion01:
            True
        jid:
            20170105195417028456
        retcode:
            0
        saltstack-node01:
            True
        [root@saltstack-node01 /srv/pillar/web]# salt -G 'os:CentOS' -b 50 test.ping
		
	https://www.unixhot.com/docs/saltstack/topics/targeting/compound.html
	https://www.unixhot.com/docs/saltstack/ref/modules/all/index.html#all-salt-modules
	[root@saltstack-node01 /usr/lib/python2.7/site-packages/salt/modules]# pwd
	/usr/lib/python2.7/site-packages/salt/modules--------------所有模块的位置
			
	Letter	 Type	               Example	                                                    Alt Delimiter?
	G	     Grains glob	       G@os:Ubuntu	                                                Yes
	E	     PCRE Minion ID	       E@web\d+\.(dev|qa|prod)\.loc	                                No
	P	     Grains PCRE	       P@os:(RedHat|Fedora|CentOS)	                                Yes
	L	     List of minions	   L@minion1.example.com,minion3.domain.com or bl*.domain.com	No
	I	     Pillar glob	       I@pdata:foobar	                                            Yes
	J	     Pillar PCRE	       J@pdata:^(foo|bar)$	                                        Yes
	S	     Subnet/IP address	   S@192.168.1.0/24 or S@192.168.1.100	                        No
	R	     Range cluster	       R@%foo.bar	                                                No

# 执行模块：

	# salt-cp '*' /etc/hosts /tmp/hehe   salt-cp是salt的复制命令

# 状态模块：

	state.highstate

	[root@saltstack-node01 ~]# salt '*' state.show_top-------- topfile里 minion要执行那些状态
	saltstack-node01:
		----------
		base:
			- web.apache
	saltstack-minion01:
		----------
		base:
			- web.apache
	[root@saltstack-node01 ~]# 
	[root@saltstack-node01 ~]# salt '*' state.single pkg.installed name=lsof ----- 单个执行某个状态

# 返回程序：

	可以讲返回结果到数据库存储 记录操作

	minion要将返回结果到数据库 minion端要装MySQL-python 
	# salt '*' state.single pkg.installed name=MySQL-python
	创建数据库
	https://www.unixhot.com/docs/saltstack/ref/returners/all/salt.returners.mysql.html#module-salt.returners.mysql
	授权账号
	MariaDB [salt]> grant all on salt.* to 'salt'@'%' identified by 'salt@pw';
	minion端改配置文件添加数据库信息
	mysql.host: 'salt'
	mysql.user: 'salt'
	mysql.pass: 'salt@pw'
	mysql.db: 'salt'
	mysql.port: 3306

	# salt '*' test.ping --return mysql
	
	MariaDB [salt]> select * from salt.salt_returns\G
	*************************** 1. row ***************************
		   fun: test.ping
		   jid: 20170602141310547013
		return: true
			id: linux-node01
	   success: 1
	  full_ret: {"fun_args": [], "jid": "20170602141310547013", "return": true, "retcode": 0, "success": true, "fun": "test.ping", "id": "linux-node01"}
	alter_time: 2017-06-02 14:13:10
	1 row in set (0.00 sec)

	MariaDB [salt]> 


# 编写执行模块：

	1、放置路径：/srv/salt/_modules

	2、命名： 文件名就是模块名

	3、刷新：# salt '*' saltutil.sync_modules

	[root@saltstack-node01 /srv/salt/_modules]# cat my_disk.py 
	def list():
	  cmd = 'df -h'
	  ret = __salt__['cmd.run'] (cmd)
	  return ret
	[root@saltstack-node01 /srv/salt/_modules]# salt '*' my_disk.list
	saltstack-node01:
		Filesystem      Size  Used Avail Use% Mounted on
		/dev/sda3        18G  2.4G   16G  14% /
		devtmpfs        480M     0  480M   0% /dev
		tmpfs           489M   28K  489M   1% /dev/shm
		tmpfs           489M   13M  477M   3% /run
		tmpfs           489M     0  489M   0% /sys/fs/cgroup
		/dev/sda1       197M  134M   63M  68% /boot
		tmpfs            98M     0   98M   0% /run/user/0

	[root@saltstack-minion01 minion]# tree
	.
	├── accumulator
	├── extmods
	│   ├── grains
	│   │   ├── my_grains.py
	│   │   └── my_grains.pyc
	│   └── modules
	│       ├── my_disk.py
	│       └── my_disk.pyc
	├── files
	│   └── base
	│       ├── _grains
	│       │   └── my_grains.py
	│       ├── _modules
	│       │   └── my_disk.py-------------------自己编写的模块会在刷新后会在minion的 /var/cache/salt/minion/files/base/_modules目录下生成一个。
	│       ├── top.sls
	│       └── web
	│           └── apache.sls
	├── highstate.cache.p
	├── module_refresh
	├── pkg_refresh
	├── proc
	└── sls.p

	10 directories, 12 files









