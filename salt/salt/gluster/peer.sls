{% set peers = salt['pillar.get']('senec:gluster:peers') %}

peer_probe:
  cmd.run:
    - name: |
        {% for peer in peers %}
        gluster peer probe {{ peer }}
        {% endfor %}
    - unless: "gluster peer status | grep 'Peer in Cluster'"
