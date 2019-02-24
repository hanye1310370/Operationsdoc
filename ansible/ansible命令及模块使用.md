# 模块
### ping模块: 测试使用
    [root@server01 ~]# ansible servers -m ping
    server02 | SUCCESS => {
    "changed": false, 
    "ping": "pong"
    }
    server03 | SUCCESS => {
    "changed": false, 
    "ping": "pong"
    }
### command模块：命令执行
    [root@server01 ~]# ansible servers -m command -a "grep www /etc/passwd"
    server02 | CHANGED | rc=0 >>
    www:x:1000:1000::/home/www:/sbin/nologin
    
    server03 | FAILED | rc=1 >>
    non-zero return code
### copy模块：文件拷贝
    [root@server01 ~]# ansible servers -m copy -a "src=/etc/passwd dest=/tmp/ owner=1004 group=1004 mode=644"
    server02 | CHANGED => {
    "changed": true, 
    "checksum": "8541f411911a9a6a8e2827fb7ef76e9aa0173110", 
    "dest": "/tmp/passwd", 
    "gid": 1004, 
    "group": "virtusers", 
    "md5sum": "e0fd9edc9597cba12307e718f079e5b1", 
    "mode": "0644", 
    "owner": "virtusers", 
    "size": 1231, 
    "src": "/root/.ansible/tmp/ansible-tmp-1551009552.89-62319587824312/source", 
    "state": "file", 
    "uid": 1004
    }
    server03 | CHANGED => {
    "changed": true, 
    "checksum": "8541f411911a9a6a8e2827fb7ef76e9aa0173110", 
    "dest": "/tmp/passwd", 
    "gid": 1004, 
    "group": "1004", 
    "md5sum": "e0fd9edc9597cba12307e718f079e5b1", 
    "mode": "0644", 
    "owner": "1004", 
    "size": 1231, 
    "src": "/root/.ansible/tmp/ansible-tmp-1551009552.89-73364213096300/source", 
    "state": "file", 
    "uid": 1004
    }

### yum模块： yum 软件管理 state{installed,present,latest,absent,removed}
    [root@server01 ~]# ansible servers -m yum -a "name=lrzsz,iftop,lsof state=installed" --- 安装
    server02 | SUCCESS => {
    "ansible_facts": {
    "pkg_mgr": "yum"
    }, 
    "changed": false, 
    "msg": "", 
    "rc": 0, 
    "results": [
    "lrzsz-0.12.20-36.el7.x86_64 providing lrzsz is already installed", 
    "iftop-1.0-0.14.pre4.el7.x86_64 providing iftop is already installed", 
    "lsof-4.87-6.el7.x86_64 providing lsof is already installed"
    ]
    }
    server03 | SUCCESS => {
    "ansible_facts": {
    "pkg_mgr": "yum"
    }, 
    "changed": false, 
    "msg": "", 
    "rc": 0, 
    "results": [
    "lrzsz-0.12.20-36.el7.x86_64 providing lrzsz is already installed", 
    "iftop-1.0-0.14.pre4.el7.x86_64 providing iftop is already installed", 
    "lsof-4.87-6.el7.x86_64 providing lsof is already installed"
    ]
    }
    [root@server01 ~]# ansible servers -m yum -a "name=vim state=absent" ----卸载
    server02 | CHANGED => {
    "ansible_facts": {
    "pkg_mgr": "yum"
    }, 
    "changed": true, 
    "msg": "", 
    "rc": 0, 
    "results": [
    "Loaded plugins: fastestmirror\nResolving Dependencies\n--> Running transaction check\n---> Package vim-enhanced.x86_64 2:7.4.160-5.el7 will be erased\n--> Finished Dependency Resolution\n\nDependencies Resolved\n\n================================================================================\n Package Arch  Version   RepositorySize\n================================================================================\nRemoving:\n vim-enhancedx86_642:7.4.160-5.el7   @base2.2 M\n\nTransaction Summary\n================================================================================\nRemove  1 Package\n\nInstalled size: 2.2 M\nDownloading packages:\nRunning transaction check\nRunning transaction test\nTransaction test succeeded\nRunning transaction\n  Erasing: 2:vim-enhanced-7.4.160-5.el7.x86_64  1/1 \n  Verifying  : 2:vim-enhanced-7.4.160-5.el7.x86_64  1/1 \n\nRemoved:\n  vim-enhanced.x86_64 2:7.4.160-5.el7   \n\nComplete!\n"
    ]
    }
    server03 | CHANGED => {
    "ansible_facts": {
    "pkg_mgr": "yum"
    }, 
    "changed": true, 
    "msg": "", 
    "rc": 0, 
    "results": [
    "Loaded plugins: fastestmirror\nResolving Dependencies\n--> Running transaction check\n---> Package vim-enhanced.x86_64 2:7.4.160-5.el7 will be erased\n--> Finished Dependency Resolution\n\nDependencies Resolved\n\n================================================================================\n Package Arch  Version   RepositorySize\n================================================================================\nRemoving:\n vim-enhancedx86_642:7.4.160-5.el7   @base2.2 M\n\nTransaction Summary\n================================================================================\nRemove  1 Package\n\nInstalled size: 2.2 M\nDownloading packages:\nRunning transaction check\nRunning transaction test\nTransaction test succeeded\nRunning transaction\n  Erasing: 2:vim-enhanced-7.4.160-5.el7.x86_64  1/1 \n  Verifying  : 2:vim-enhanced-7.4.160-5.el7.x86_64  1/1 \n\nRemoved:\n  vim-enhanced.x86_64 2:7.4.160-5.el7   \n\nComplete!\n"
    ]
    }

### file模块：
    [root@server01 ~]# ansible servers -m file -a "path=/tmp/test state=directory mode=755" --------- 创建目录
    server02 | CHANGED => {
    "changed": true, 
    "gid": 0, 
    "group": "root", 
    "mode": "0755", 
    "owner": "root", 
    "path": "/tmp/test", 
    "size": 4096, 
    "state": "directory", 
    "uid": 0
    }
    server03 | CHANGED => {
    "changed": true, 
    "gid": 0, 
    "group": "root", 
    "mode": "0755", 
    "owner": "root", 
    "path": "/tmp/test", 
    "size": 4096, 
    "state": "directory", 
    "uid": 0
    }
    [root@server01 ~]# ansible servers -m file -a "path=/tmp/test state=directory owner=nobody group=nobody mode=700" --- 目录存在则修改目录权限
    server02 | CHANGED => {
    "changed": true, 
    "gid": 99, 
    "group": "nobody", 
    "mode": "0700", 
    "owner": "nobody", 
    "path": "/tmp/test", 
    "size": 4096, 
    "state": "directory", 
    "uid": 99
    }
    server03 | CHANGED => {
    "changed": true, 
    "gid": 99, 
    "group": "nobody", 
    "mode": "0700", 
    "owner": "nobody", 
    "path": "/tmp/test", 
    "size": 4096, 
    "state": "directory", 
    "uid": 99
    }
### user模块：
    [root@server01 ~]# ansible servers -m user -a "name=wangwei home=/home/wangwei shell=/bin/bash group=root" ---创建用户
    server02 | CHANGED => {
    "append": false, 
    "changed": true, 
    "comment": "", 
    "group": 0, 
    "home": "/home/wangwei", 
    "move_home": false, 
    "name": "wangwei", 
    "shell": "/bin/bash", 
    "state": "present", 
    "uid": 1001
    }
    server03 | CHANGED => {
    "changed": true, 
    "comment": "", 
    "create_home": true, 
    "group": 0, 
    "home": "/home/wangwei", 
    "name": "wangwei", 
    "shell": "/bin/bash", 
    "state": "present", 
    "system": false, 
    "uid": 1000
    }
    [root@server01 ~]# ansible servers -m user -a "name=wangwei home=/home/wangwei shell=/bin/bash group=root state=absent" --- 删除用户
    server02 | CHANGED => {
    "changed": true, 
    "force": false, 
    "name": "wangwei", 
    "remove": false, 
    "state": "absent", 
    "stderr": "userdel: group wangwei not removed because it is not the primary group of user wangwei.\n", 
    "stderr_lines": [
    "userdel: group wangwei not removed because it is not the primary group of user wangwei."
    ]
    }
    server03 | CHANGED => {
    "changed": true, 
    "force": false, 
    "name": "wangwei", 
    "remove": false, 
    "state": "absent"
    }
### cron模块：
    [root@server01 ~]# ansible servers -m cron -a "minute=0 hour=0 day=* month=* weekday=* name='ntp' job='/usr/local/ntpdate times.aliyun/com >/dev/null 2>&1'" ---创建定时任务
    server02 | CHANGED => {
    "changed": true, 
    "envs": [], 
    "jobs": [
    "ntpdate", 
    "ntp"
    ]
    }
    server03 | CHANGED => {
    "changed": true, 
    "envs": [], 
    "jobs": [
    "ntpdate", 
    "ntp"
    ]
    }
### synchronize模块:
    [root@server01 ~]# ansible servers -m synchronize -a "src=/tmp/ dest=/opt/test/ compress=yes delete=yes rsync_opts=--no-motd,--exclude=.txt"
    server02 | CHANGED => {
    "changed": true, 
    "cmd": "/usr/bin/rsync --delay-updates -F --compress --delete-after --archive --rsh=/usr/bin/ssh -S none -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null --no-motd --exclude=.txt --out-format=<<CHANGED>>%i %n%L /tmp/ server02:/opt/test/", 
    "msg": ".d..tp..... ./\ncS+++++++++ Aegis-<Guid(5A2C30A2-A87D-490A-9281-6765EDAD7CBA)>\n<f+++++++++ xtx.txt\n<f+++++++++ yum_save_tx.2019-02-21.16-57.T9sIvf.yumtx\n<f+++++++++ yum_save_tx.2019-02-21.17-03.UKkeWK.yumtx\ncd+++++++++ .ICE-unix/\ncd+++++++++ .Test-unix/\ncd+++++++++ .X11-unix/\ncd+++++++++ .XIM-unix/\ncd+++++++++ .font-unix/\ncd+++++++++ ansible_synchronize_payload_F9mAqY/\n<f+++++++++ ansible_synchronize_payload_F9mAqY/__main__.py\n<f+++++++++ ansible_synchronize_payload_F9mAqY/__main__.pyc\n<f+++++++++ ansible_synchronize_payload_F9mAqY/ansible_synchronize_payload.zip\ncd+++++++++ ansible_synchronize_payload_GeYBzL/\n<f+++++++++ ansible_synchronize_payload_GeYBzL/__main__.py\n<f+++++++++ ansible_synchronize_payload_GeYBzL/__main__.pyc\n<f+++++++++ ansible_synchronize_payload_GeYBzL/ansible_synchronize_payload.zip\ncd+++++++++ pear/\ncd+++++++++ pear/temp/\ncd+++++++++ systemd-private-3ca6a8837cfb46c58c0aaa9fb3c4b5df-chronyd.service-yzg31J/\ncd+++++++++ systemd-private-3ca6a8837cfb46c58c0aaa9fb3c4b5df-chronyd.service-yzg31J/tmp/\n*deleting   mmm\n", 
    "rc": 0, 
    "stdout_lines": [
    ".d..tp..... ./", 
    "cS+++++++++ Aegis-<Guid(5A2C30A2-A87D-490A-9281-6765EDAD7CBA)>", 
    "<f+++++++++ xtx.txt", 
    "<f+++++++++ yum_save_tx.2019-02-21.16-57.T9sIvf.yumtx", 
    "<f+++++++++ yum_save_tx.2019-02-21.17-03.UKkeWK.yumtx", 
    "cd+++++++++ .ICE-unix/", 
    "cd+++++++++ .Test-unix/", 
    "cd+++++++++ .X11-unix/", 
    "cd+++++++++ .XIM-unix/", 
    "cd+++++++++ .font-unix/", 
    "cd+++++++++ ansible_synchronize_payload_F9mAqY/", 
    "<f+++++++++ ansible_synchronize_payload_F9mAqY/__main__.py", 
    "<f+++++++++ ansible_synchronize_payload_F9mAqY/__main__.pyc", 
    "<f+++++++++ ansible_synchronize_payload_F9mAqY/ansible_synchronize_payload.zip", 
    "cd+++++++++ ansible_synchronize_payload_GeYBzL/", 
    "<f+++++++++ ansible_synchronize_payload_GeYBzL/__main__.py", 
    "<f+++++++++ ansible_synchronize_payload_GeYBzL/__main__.pyc", 
    "<f+++++++++ ansible_synchronize_payload_GeYBzL/ansible_synchronize_payload.zip", 
    "cd+++++++++ pear/", 
    "cd+++++++++ pear/temp/", 
    "cd+++++++++ systemd-private-3ca6a8837cfb46c58c0aaa9fb3c4b5df-chronyd.service-yzg31J/", 
    "cd+++++++++ systemd-private-3ca6a8837cfb46c58c0aaa9fb3c4b5df-chronyd.service-yzg31J/tmp/", 
    "*deleting   mmm"
    ]
    }
    server03 | CHANGED => {
    "changed": true, 
    "cmd": "/usr/bin/rsync --delay-updates -F --compress --delete-after --archive --rsh=/usr/bin/ssh -S none -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null --no-motd --exclude=.txt --out-format=<<CHANGED>>%i %n%L /tmp/ server03:/opt/test/", 
    "msg": ".d..tp..... ./\ncS+++++++++ Aegis-<Guid(5A2C30A2-A87D-490A-9281-6765EDAD7CBA)>\n<f+++++++++ xtx.txt\n<f+++++++++ yum_save_tx.2019-02-21.16-57.T9sIvf.yumtx\n<f+++++++++ yum_save_tx.2019-02-21.17-03.UKkeWK.yumtx\ncd+++++++++ .ICE-unix/\ncd+++++++++ .Test-unix/\ncd+++++++++ .X11-unix/\ncd+++++++++ .XIM-unix/\ncd+++++++++ .font-unix/\ncd+++++++++ ansible_synchronize_payload_GeYBzL/\n<f+++++++++ ansible_synchronize_payload_GeYBzL/__main__.py\n<f+++++++++ ansible_synchronize_payload_GeYBzL/__main__.pyc\n<f+++++++++ ansible_synchronize_payload_GeYBzL/ansible_synchronize_payload.zip\ncd+++++++++ pear/\ncd+++++++++ pear/temp/\ncd+++++++++ systemd-private-3ca6a8837cfb46c58c0aaa9fb3c4b5df-chronyd.service-yzg31J/\ncd+++++++++ systemd-private-3ca6a8837cfb46c58c0aaa9fb3c4b5df-chronyd.service-yzg31J/tmp/\n", 
    "rc": 0, 
    "stdout_lines": [
    ".d..tp..... ./", 
    "cS+++++++++ Aegis-<Guid(5A2C30A2-A87D-490A-9281-6765EDAD7CBA)>", 
    "<f+++++++++ xtx.txt", 
    "<f+++++++++ yum_save_tx.2019-02-21.16-57.T9sIvf.yumtx", 
    "<f+++++++++ yum_save_tx.2019-02-21.17-03.UKkeWK.yumtx", 
    "cd+++++++++ .ICE-unix/", 
    "cd+++++++++ .Test-unix/", 
    "cd+++++++++ .X11-unix/", 
    "cd+++++++++ .XIM-unix/", 
    "cd+++++++++ .font-unix/", 
    "cd+++++++++ ansible_synchronize_payload_GeYBzL/", 
    "<f+++++++++ ansible_synchronize_payload_GeYBzL/__main__.py", 
    "<f+++++++++ ansible_synchronize_payload_GeYBzL/__main__.pyc", 
    "<f+++++++++ ansible_synchronize_payload_GeYBzL/ansible_synchronize_payload.zip", 
    "cd+++++++++ pear/", 
    "cd+++++++++ pear/temp/", 
    "cd+++++++++ systemd-private-3ca6a8837cfb46c58c0aaa9fb3c4b5df-chronyd.service-yzg31J/", 
    "cd+++++++++ systemd-private-3ca6a8837cfb46c58c0aaa9fb3c4b5df-chronyd.service-yzg31J/tmp/"
    ]
    }
### shell 模块：
    [root@server01 ~]# ansible servers -m shell -a "cat /etc/redhat-release && ifconfig eth0"
    server02 | CHANGED | rc=0 >>
    CentOS Linux release 7.6.1810 (Core) 
    eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
    inet 172.26.190.156  netmask 255.255.240.0  broadcast 172.26.191.255
    ether 00:16:3e:03:49:fe  txqueuelen 1000  (Ethernet)
    RX packets 96331371  bytes 34217330960 (31.8 GiB)
    RX errors 0  dropped 0  overruns 0  frame 0
    TX packets 83604187  bytes 54585945801 (50.8 GiB)
    TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
    
    server03 | CHANGED | rc=0 >>
    CentOS Linux release 7.6.1810 (Core) 
    eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
    inet 172.26.190.157  netmask 255.255.240.0  broadcast 172.26.191.255
    ether 00:16:3e:03:34:c3  txqueuelen 1000  (Ethernet)
    RX packets 70282111  bytes 32030249299 (29.8 GiB)
    RX errors 0  dropped 0  overruns 0  frame 0
    TX packets 57286536  bytes 53643424222 (49.9 GiB)
    TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
### service模块
    [root@server01 ~]# ansible servers -m service -a "name=crond enabled=yes  state=started"
    server02 | SUCCESS => {
    "changed": false, 
    "enabled": true, 
    "name": "crond", 
    "state": "started", 
    "status": {
    "ActiveEnterTimestamp": "Tue 2019-02-19 08:08:09 CST", 
    "ActiveEnterTimestampMonotonic": "15380805", 
    "ActiveExitTimestampMonotonic": "0", 
    "ActiveState": "active", 
    "After": "auditd.service system.slice time-sync.target basic.target systemd-user-sessions.service systemd-journald.socket", 
    "AllowIsolate": "no", 
    "AmbientCapabilities": "0", 
    "AssertResult": "yes", 
    "AssertTimestamp": "Tue 2019-02-19 08:08:09 CST", 
    "AssertTimestampMonotonic": "15374984", 
    "Before": "shutdown.target multi-user.target", 
    "BlockIOAccounting": "no", 
    "BlockIOWeight": "18446744073709551615", 
    ........
