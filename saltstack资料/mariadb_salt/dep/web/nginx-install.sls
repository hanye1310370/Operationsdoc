{% set nginx_tar = 'nginx-1.12.1.tar.gz' %}
{% set nginx_dr = 'nginx-1.12.1' %}
{% set nginx_source = 'salt://web/file/nginx-1.12.1.tar.gz' %}
include:
  - web.requrie.package
nginx-install:
  file.managed:
    - name: /usr/local/src/{{ nginx_tar }}
    - source: {{ nginx_source }}
    - mode: 755
    - user: root
    - group: root
  cmd.run:
    - name: cd /usr/local/src/ && tar xf {{ nginx_tar }} && cd {{ nginx_dr }} && ./configure --prefix=/usr/local/{{ nginx_dr }} --user=www --group=www --with-http_ssl_module --with-pcre  --with-http_stub_status_module && make && make install && ln -s /usr/local/{{ nginx_dr }} /usr/local/nginx &&  mkdir /usr/local/{{ nginx_dr }}/conf/vhost
    - unless: test -L /usr/local/nginx
    - require:
      - pkg: dependency-package
      - file: nginx-install

nginx-script:
  file.managed:
    - name: /etc/init.d/nginx
    - source: salt://web/file/nginx
    - mode: 755
    - user: root
    - group: root
  cmd.run:
    - name: chkconfig --add nginx && chkconfig nginx on
    - unless: chkconfig --list | grep nginx

nginx-config:
  file.managed:
    - name: /usr/local/nginx/conf/nginx.conf
    - source: salt://web/file/nginx.conf.temple
    - mode: 755
    - user: root
    - group: root
    - require:
      - cmd: nginx-install

nginx-web-config:
  file.managed:
    - name: /usr/local/nginx/conf/vhost/www.example.com.conf
    - source: salt://web/file/www.example.com.conf.temple
    - mode: 755
    - user: root
    - group: root
    - require:
      - cmd: nginx-install

nginx-service:
  service.running:
    - name: nginx
    - enable: True
    - reload: True
    - require:
      - cmd: nginx-script
    - watch:
      - file: /usr/local/nginx/conf/vhost/www.example.com.conf
      - file: /usr/local/nginx/conf/nginx.conf
