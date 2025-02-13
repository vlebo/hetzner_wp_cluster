install_nginx:
  pkg.installed:
    - name: nginx

enable_nginx:
  service.running:
    - name: nginx
    - enable: True
    - require:
      - pkg: install_nginx
