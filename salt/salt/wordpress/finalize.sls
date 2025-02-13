{% set config = salt['pillar.get']('senec:wordpress') %}
{% set domain = salt['pillar.get']('senec:common:domain') %}

wordpress_initial_setup:
  cmd.run:
    - name: >
        wp core install
        --path={{ config.wp_dir }}
        --url="https://{{ domain }}"
        --title="{{ config.site_title }}"
        --admin_user="{{ config.admin_user }}"
        --admin_password="{{ config.admin_password }}"
        --admin_email="{{ config.admin_email }}"
        --skip-email
    - runas: www-data
    
wordpress_disable_pub:
  cmd.run:
    - name: wp option update blog_public 0 --path={{ config.wp_dir }}
    - runas: www-data
