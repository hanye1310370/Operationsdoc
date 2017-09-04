# 无master的架构：
	单台机器在没有master的情况下管理：
	使用salt-call 命令运行任务
	修改minion配置文件
	[root@linux-node02 ~]# vim /etc/salt/minion
	#file_client: remote
	修改为：
	file_client: local
	file_roots
	pillar_roots
	[root@linux-node02 ~]# salt-call grains.item fqdn_ip4
	local:
		----------
		fqdn_ip4:
			- 10.0.0.12
	[root@linux-node02 ~]# 
	
# saltstack安装salt-master


## 多master架构

## key master minion

	[root@linux-node02 ~]# vim /etc/salt/minion
	# Set the location of the salt master server. If the master server cannot be
	# resolved, then the minion will fail to start.
	master:
	  - 10.0.0.11
	  - 10.0.0.12
	  
	  
	salt-sydic salt中继：注意事项：如果更改salt高级master 需要删除syndic的master公钥
	
		1、salt-syndic必须运行在一个master上
		2、并且sydic要连接另外一个master。比他更高及的master
		3、重点：syndic的file_roots和pillar_roots必须与高级master一致
		4、minon 返回数据是给salt-sydic
		缺点：高级的master并不知道minion数量
		
	例子：
		salt-master上安装syndic
		[root@linux-node01 ~]# yum install salt-syndic -y
		
		vim /etc/salt/master
		#####          Syndic settings       #####
		##########################################
		# The Salt syndic is used to pass commands through a master from a higher
		# master. Using the syndic is simple. If this is a master that will have
		# syndic servers(s) below it, then set the "order_masters" setting to True.
		#
		# If this is a master that will be running a syndic daemon for passthrough, then
		# the "syndic_master" setting needs to be set to the location of the master server
		# to receive commands from.
	
		# Set the order_masters setting to True if this master will command lower
		# masters' syndic interfaces.
		#order_masters: False
	
		# If this master will be running a salt syndic daemon, syndic_master tells
		# this master where to receive commands from.
		syndic_master: 10.0.0.11--------------------------配置高级master的地址
		
		[root@linux-node01 jobs]# systemctl restart salt-master
		[root@linux-node01 jobs]# systemctl restart salt-syndic.service 
		
		salt-master更高级的master上修改配置文件：
		[root@linux-node02 ~]# vim /etc/salt/master
		order_masters: True------------------------------配置高级master为高级master
	
		[root@linux-node02 ~]# salt-key
		Accepted Keys:
		Denied Keys:
		Unaccepted Keys:
		linux-node01
		Rejected Keys:
		[root@linux-node02 ~]# salt-key -A--------------添加syndic为高级master的minion
		[root@linux-node02 ~]# salt '*' test.ping
		linux-node01:
			True
		linux-node02:
			True
			
			
	salt-ssh使用：无非就是使用ssh协议通信
	    修改配置：
		[root@linux-node01 srv]# cat /etc/salt/roster 
		# Sample salt-ssh config file
		#web1:
		#  host: 192.168.42.1 # The IP addr or DNS hostname
		#  user: fred         # Remote executions will be executed as user fred
		#  passwd: foobarbaz  # The password to use for login, if omitted, keys are used
		#  sudo: True         # Whether to sudo to root, not enabled by default
		#web2:
		#  host: 192.168.42.2
		linux-node02:-------------给salt-ssh管理的主机定义目标名字
		  host: 10.0.0.12---------地址
		  user: root--------------账号
		  passwd: 123456----------密码
		  port: 22----------------端口
		linux-node01:
		  host: 10.0.0.11
		  user: root
		  passwd: 123456
		  port: 22
		[root@linux-node01 srv]# 
		
		[root@linux-node01 srv]# salt-ssh -i '*' cmd.run 'w' ---------- -i参数非交互
		[root@linux-node01 srv]# salt-ssh -i '*' -r 'w' --------------- -r参数同cmd.run
		
		salt-ssh -i '*' grains.items
		[root@linux-node01 srv]# salt-ssh -i '*' state.highstate 
		
		[root@linux-node01 .ssh]# cat ~/.ssh/config 
		StrickHostKeyChecking no --------------------- .ssh文件夹下配置此文件跳过认证交互
	
	




	

