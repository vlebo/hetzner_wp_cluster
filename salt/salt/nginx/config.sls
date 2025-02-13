{% set server_name = salt['pillar.get']('senec:common:domain') %}
{% set web_root = salt['pillar.get']('senec:wordpress:wp_dir') %}

nginx_wordpress_config:
  file.managed:
    - name: /etc/nginx/sites-available/wordpress
    - source: salt://nginx/files/wordpress.conf.j2
    - template: jinja
    - context:
        server_name: {{ server_name }}
        web_root: {{ web_root }}
    - require:
      - pkg: install_nginx
    - watch_in:
      - service: enable_nginx

enable_wordpress_site:
  file.symlink:
    - name: /etc/nginx/sites-enabled/wordpress
    - target: /etc/nginx/sites-available/wordpress
    - require:
      - file: nginx_wordpress_config

remove_default_site:
  file.absent:
    - name: /etc/nginx/sites-enabled/default
    - require:
      - file: enable_wordpress_site

restart_nginx:
  service.running:
    - name: nginx
    - enable: True
    - reload: True
    - watch:
      - file: nginx_wordpress_config
      - file: enable_wordpress_site
      - file: remove_default_site
