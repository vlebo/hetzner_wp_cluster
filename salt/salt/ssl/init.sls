{% set config = salt['pillar.get']('senec:common') %} 

install_certbot:
  pkg.installed:
    - name: certbot

obtain_ssl_certificate:
  cmd.run:
    - name: certbot certonly --standalone --agree-tos --email {{ config.email }} -d {{ config.domain }} --non-interactive
    - unless: test -f /etc/letsencrypt/live/{{ config.domain }}/fullchain.pem
    - require:
      - pkg: install_certbot

enable_auto_renewal:
  cron.present:
    - name: "/usr/bin/certbot renew --quiet --standalone"
    - user: root
    - minute: "0"
    - hour: "3"
