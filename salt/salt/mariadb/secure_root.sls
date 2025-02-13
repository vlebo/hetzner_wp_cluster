{% set config = salt['pillar.get']('senec:mariadb') %}
{% set marker_file = "/var/lib/mysql/.root_secured" %}

# Update localhost root password and create new root user
secure_mysql:
  cmd.run:
    - name: >
        mysql --user=root --execute="
        ALTER USER 'root'@'localhost' IDENTIFIED BY '{{ config.root_password }}';
        DELETE FROM mysql.user WHERE User='';
        DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
        DROP DATABASE IF EXISTS test;
        DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
        CREATE USER '{{ config.senec_root_user }}'@'%' IDENTIFIED BY '{{ config.senec_root_password }}';
        GRANT ALL PRIVILEGES ON *.* TO '{{ config.senec_root_user }}'@'%' WITH GRANT OPTION;
        FLUSH PRIVILEGES;"
    - unless: "test -f {{ marker_file }}"

# Create a marker file to prevent re-running bootstrap
set_root_secured_marker:
  file.managed:
    - name: {{ marker_file }}
    - contents: "Secured on {{ salt['cmd.run']('date') }}"
    - require:
      - cmd: secure_mysql