{% set servers = salt['pillar.get']('senec:common:web_servers') %} 
{% set domain = salt['pillar.get']('senec:common:domain') %} 

haproxy_config:
  file.managed:
    - name: /etc/haproxy/haproxy.cfg
    - source: salt://haproxy/files/haproxy.cfg.j2
    - template: jinja
    - context:
        web_servers: {{ servers }}
        db_servers: {{ servers }}
        domain: {{ domain }}

restart_haproxy:
  service.running:
    - name: haproxy
    - enable: True
    - watch:
      - file: haproxy_config
    - require:
      - file: haproxy_config
    - reload: True