{% set config = salt['pillar.get']('senec:gluster') %}

install_glusterfs:
  pkg.installed:
    - names:
      - {{ config.server_pkg }}
      - {{ config.client_pkg }}
      - attr  # Required for extended attributes

start_glusterfs:
  service.running:
    - name: {{ config.service_name }}
    - enable: True
    - require:
      - pkg: install_glusterfs
