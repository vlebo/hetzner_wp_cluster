download_wordpress:
  file.managed:
    - name: /srv/salt/wordpress.tar.gz
    - source: https://wordpress.org/latest.tar.gz
    - skip_verify: True
    - mode: "0644"
    - retry: 3  # Retry in case of network failure