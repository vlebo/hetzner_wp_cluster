{% set config = salt['pillar.get']('senec:mariadb') %}

# Deploy Galera Configuration
mariadb_galera_config:
  file.managed:
    - name: /etc/mysql/mariadb.conf.d/50-galera.cnf
    - source: salt://mariadb/files/galera.cnf.j2
    - template: jinja
    - context:
        user: {{ config.senec_root_user }}
        password: {{ config.senec_root_password }}


update_mariadb_bind_address:
  file.replace:
    - name: /etc/mysql/mariadb.conf.d/50-server.cnf
    - pattern: '^bind-address\s*=\s*127\.0\.0\.1'
    - repl: 'bind-address = 0.0.0.0'
    - backup: True
    - show_changes: True