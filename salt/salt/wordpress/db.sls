# Load pillar values
{% set config = salt['pillar.get']('senec:wordpress') %}
{% set db = salt['pillar.get']('senec:mariadb') %}

# Install required packages
install_mariadb_packages:
  pkg.installed:
    - names:
      - mariadb-server
      - mariadb-client
      - python3-pymysql  # Required for Salt's MySQL module

# Create MartiaDB database for WordPress
create_wordpress_db:
  mysql_database.present:
    - name: {{ config.db_name }}
    - connection_host: {{ config.db_host }}
    - connection_port: {{ config.db_port }}
    - connection_user: {{ db.senec_root_user }}
    - connection_pass: {{ db.senec_root_password }}

# Create MartiaDB user for WordPress
create_wordpress_user:
  mysql_user.present:
    - name: {{ config.db_user }}
    - password: {{ config.db_password }}
    - host: '%'
    - require:
      - mysql_database: create_wordpress_db
    - use:
      - mysql_database: create_wordpress_db

# Grant privileges to the WordPress user
grant_wordpress_privileges:
  mysql_grants.present:
    - grant: ALL PRIVILEGES
    - database: "{{ config.db_name }}.*"
    - user: {{ config.db_user }}
    - host: '%'
    - require:
      - mysql_user: create_wordpress_user
    - use:
      - mysql_database: create_wordpress_db