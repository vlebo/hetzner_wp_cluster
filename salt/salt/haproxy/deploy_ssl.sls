{% set domain = salt['pillar.get']('senec:common:domain') %} 


combine_ssl_key:
  cmd.run:
    - name: "cat /etc/letsencrypt/live/{{ domain }}/privkey.pem /etc/letsencrypt/live/{{ domain }}/fullchain.pem > /etc/haproxy/{{ domain }}.pem"
    - unless: test -f /etc/haproxy/{{ domain }}.pem
