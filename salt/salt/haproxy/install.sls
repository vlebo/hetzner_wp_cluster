install_haproxy:
  pkg.installed:
    - name: haproxy

enable_haproxy:
  service.running:
    - name: haproxy
    - enable: True
    - require:
      - pkg: install_haproxy
