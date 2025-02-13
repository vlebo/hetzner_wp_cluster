{% set domain = salt['pillar.get']('senec:common:domain') %}
{% set wp_dir = salt['pillar.get']('senec:wordpress:wp_dir') %}

configure_wp_config:
  file.managed:
    - name: /var/www/senec/wordpress/wp-config.php
    - source: salt://wordpress/files/wp-config.php.j2
    - template: jinja
    - makedirs: True
    - context:
        domain: {{ domain }}
    - user: www-data
    - group: www-data
    - mode: "0644"

restart_php:
  service.running:
    - name: php8.1-fpm
    - enable: True
    - watch:
      - file: configure_wp_config
