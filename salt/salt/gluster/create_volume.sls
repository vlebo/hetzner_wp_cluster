{% set bricks_path = salt['pillar.get']('senec:gluster:bricks_path') %}
{% set servers = salt['pillar.get']('senec:common:web_servers') %}
{% set volume_name = salt['pillar.get']('senec:gluster:volume_name') %}

create_volume:
  cmd.run:
    - name: |
        gluster volume create {{ volume_name }} replica 3 transport tcp \
        {%- for server in servers %}
        {{ server }}:{{ bricks_path }} \
        {%- endfor %}
        force
    - unless: "gluster volume info {{ volume_name }}"

start_volume:
  cmd.run:
    - name: gluster volume start {{ volume_name }}
    - unless: "gluster volume info {{ volume_name }} | grep 'Status: Started'"
