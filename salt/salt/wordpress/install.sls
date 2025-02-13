{% set config = salt['pillar.get']('senec:wordpress') %}

extract_wordpress:
  archive.extracted:
    - name: {{ config.install_dir }}
    - source: salt:///wordpress.tar.gz
    - unless: {{ config.install_dir }}/wordpress/index.php
    - archive_format: tar
    - enforce_toplevel: False
    - user: www-data
    - group: www-data

set_permissions:
  file.directory:
    - name: {{ config.install_dir }}
    - user: www-data
    - group: www-data
    - mode: "0755"
    - output_loglevel: quiet
    - recurse:
      - user
      - group
      - mode
    - require:
      - archive: extract_wordpress
