# MySQL5.7安装部署文档
#### 创建mysql用户
> useradd mysql -M -s /sbin/nologin && mkdir /usr/local/mysql/{bin,data,etc,logs} -p chown -R /usr/local/mysql
#### 下载mysql二进制安装包
> wget http://mirrors.163.com/mysql/Downloads/MySQL-5.7/mysql-5.7.25-el7-x86_64.tar.gz
#### 解压并安装
    tar xf mysql-5.7.25-el7-x86_64.tar.gz -C /usr/local/src/
    cd /usr/local/src/mysql-5.7.25-el7-x86_64
    ./bin/mysqld --initialize --basedir=/usr/local/mysql/ --datadir=/usr/local/mysql/data --user=mysql
#### 因为包里没有配置文件模板，创建mysql.cnf配置文件
    cd /usr/local/mysql/etc/
    cat > my.cnf << EOF
    [client]
    port = 3306
    socket = /tmp/mysql.sock
    default-character-set = utf8mb4
    
    [mysql]
    prompt="MySQL [\\d]> "
    no-auto-rehash
    
    [mysqld]
    port = 3306
    socket = /tmp/mysql.sock
    
    basedir = /usr/local/mysql
    datadir = /usr/local/mysql/data
    pid-file = /usr/local/mysql/data/mysql.pid
    user = mysql
    bind-address = 0.0.0.0
    server-id = 1
    
    init-connect = 'SET NAMES utf8mb4'
    character-set-server = utf8mb4
    
    skip-name-resolve
    back_log = 300
    
    max_connections = 1000
    max_connect_errors = 6000
    open_files_limit = 65535
    table_open_cache = 128
    max_allowed_packet = 500M
    binlog_cache_size = 1M
    max_heap_table_size = 8M
    tmp_table_size = 16M
    
    read_buffer_size = 2M
    read_rnd_buffer_size = 8M
    sort_buffer_size = 8M
    join_buffer_size = 8M
    key_buffer_size = 4M
    
    thread_cache_size = 8
    
    query_cache_type = 1
    query_cache_size = 8M
    query_cache_limit = 2M
    
    ft_min_word_len = 4
    
    log_bin = mysql-bin
    binlog_format = mixed
    expire_logs_days = 7
    
    log_error = /usr/local/mysql/logs/mysql-error.log
    slow_query_log = 1
    long_query_time = 1
    slow_query_log_file = /usr/local/mysql/logs/mysql-slow.log
    
    performance_schema = 0
    explicit_defaults_for_timestamp
    
    skip-external-locking
    
    default_storage_engine = InnoDB

    innodb_file_per_table = 1
    innodb_open_files = 500
    innodb_buffer_pool_size = 64M
    innodb_write_io_threads = 4
    innodb_read_io_threads = 4
    innodb_thread_concurrency = 0
    innodb_purge_threads = 1
    innodb_flush_log_at_trx_commit = 2
    innodb_log_buffer_size = 2M
    innodb_log_file_size = 32M
    innodb_log_files_in_group = 3
    innodb_max_dirty_pages_pct = 90
    innodb_lock_wait_timeout = 120
    
    bulk_insert_buffer_size = 8M
    myisam_sort_buffer_size = 8M
    myisam_max_sort_file_size = 10G
    myisam_repair_threads = 1
    
    interactive_timeout = 28800
    wait_timeout = 28800
    
    [mysqldump]
    quick
    max_allowed_packet = 500M
    
    [myisamchk]
    key_buffer_size = 8M
    sort_buffer_size = 8M
    read_buffer = 4M
    write_buffer = 4M
    EOF
### 创建mysql systemd管理的启动文件
    [root@server01 include]# cat /usr/lib/systemd/system/mysql.service 
    
    [Unit]
    Description=mysql
    After=network.target syslog.target
    
    [Install]
    WantedBy=multi-user.target
    Alias=mysqld.service
    
    [Service]
    EnvironmentFile=-/etc/sysconfig/mysql
    ExecStart=/usr/mysql/bin/mysqld_safe --basedir=/usr/local/mysql --defaults-file=/usr/local/mysql/etc/my.cnf
    TimeoutStartSec=0
    TimeoutStopSec=900
    LimitNOFILE = 5000
    Restart=on-failure
    RestartPreventExitStartus=1
    PrivateTmp=false



    
