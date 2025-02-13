{% set config = salt['pillar.get']('senec:mariadb') %}

# Download and execute the official MariaDB repo setup script
setup_mariadb_repo:
  cmd.run:
    - name: "curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash"
    - unless: "test -f /etc/apt/sources.list.d/mariadb.list"

# Install MariaDB Server
install_mariadb:
  pkg.installed:
    - names:
      - {{ config.pkg_name }}
    - require:
      - cmd: setup_mariadb_repo

# Ensure MariaDB is enabled and started
enable_mariadb_service:
  service.running:
    - name: {{ config.service_name }}
    - enable: True
    - require:
      - pkg: install_mariadb
