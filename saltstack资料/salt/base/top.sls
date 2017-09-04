base:
  '*':
    - init.init
prod:
  'linux-node*':
    - cluster.haproxy-outside
    - cluster.haproxy-outside-keepalived
    - bbs.web
  'linux-node02':
    - bbs.memcached
