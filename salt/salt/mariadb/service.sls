# Start MariaDB normally on all nodes
mariadb-start:
  service.running:
    - name: mariadb
    - enable: true
