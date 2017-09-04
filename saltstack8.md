# 执行结果返回保存：
	[root@linux-node01 ~]# cd /var/cache/salt/master/
	[root@linux-node01 master]# cd jobs/
	[root@linux-node01 jobs]# ls
	00  05  0e  14  1b  23  2c  33  3c  45  4e  59  61  6b  72  7a  82  89  92  97  a1  a7  ac  b3  b9  be  c7  ce  d5  dd  e4  eb  f2  fa
	01  08  0f  15  1d  25  2d  36  3d  46  52  5a  63  6d  73  7c  83  8b  93  98  a3  a8  ad  b4  ba  bf  ca  cf  d6  de  e5  ed  f3  fc
	02  09  10  16  1e  26  2e  37  3e  49  54  5b  65  6e  77  7e  85  8e  94  99  a4  a9  ae  b6  bb  c0  cb  d2  d7  e1  e8  ef  f6  fd
	03  0a  11  18  21  29  2f  38  40  4a  56  5d  66  70  78  80  86  8f  95  9c  a5  aa  b0  b7  bc  c4  cc  d3  da  e2  e9  f0  f8  fe
	04  0c  12  1a  22  2b  30  39  43  4d  58  60  69  71  79  81  88  91  96  a0  a6  ab  b2  b8  bd  c5  cd  d4  dc  e3  ea  f1  f9  ff
	[root@linux-node01 jobs]#
	
# jobcache写到数据库：
	[root@linux-node01 jobs]# vim /etc/salt/master
	######    Miscellaneous  settings     ######
	############################################
	# Default match type for filtering events tags: startswith, endswith, find, regex, fnmatch
	#event_match_type: startswith
	master_job_cache: mysql
	mysql.host: '10.0.0.11'
	mysql.user: 'salt'
	mysql.pass: 'salt@pw'
	mysql.db: 'salt'
	mysql.port: 3306
	# Save runner returns to the job cache
	#runner_returns: True
	
# job执行模块：
	[root@linux-node01 jobs]# salt '*' saltutil.running
	linux-node02:
	linux-node01:
	[root@linux-node01 jobs]# 
	
# 列出jobcache：
	[root@linux-node01 jobs]# salt-run jobs.list_jobs ------列出当前job cache执行过的任务
	20170608161012443478:
		----------
		Arguments:
		Function:

# 看以前执行过的任务的执行结果：
	[root@linux-node01 jobs]# salt-run jobs.lookup_jid 20170608161012443478
	linux-node02:
		True
	[root@linux-node01 jobs]# 
	
# 看saltstack版本：
	[root@linux-node01 jobs]# salt-run manage.versions
	Master:
		2016.11.5
	Up to date:
		----------
		linux-node01:
			2016.11.5
		linux-node02:
			2016.11.5
	[root@linux-node01 jobs]# 
	
	

