# Define variables
{% set first_node = salt['pillar.get']('senec:mariadb:db_servers')[0] %}
{% set marker_file = "/var/lib/mysql/.galera_bootstrapped" %}

# Only execute the bootstrap process if marker file doesn't exist
{% if not salt['file.file_exists'](marker_file) %}

# Stop MariaDB on all nodes for initial setup
mariadb-stop:
  service.dead:
    - name: mariadb

# Bootstrap Galera only on the first node
{% if grains['fqdn'] == first_node %}
galera-bootstrap:
  cmd.run:
    - name: galera_new_cluster
    - require:
      - service: mariadb-stop
{% endif %}

# Create marker file on ALL nodes, not just the first one
set_galera_bootstrapped_marker:
  file.managed:
    - name: {{ marker_file }}
    - contents: |
        Bootstrapped on {{ salt['cmd.run']('date') }}
        Do not delete this file - it prevents destructive re-bootstrapping
    - mode: 644
{% if grains['fqdn'] == first_node %}
    - require:
      - cmd: galera-bootstrap
{% endif %}

{% else %}
# If marker exists, do nothing and succeed
bootstrap-skipped:
  test.succeed_without_changes:
    - name: "Skipping bootstrap - cluster was previously bootstrapped"
{% endif %}