ensure_mine_config:
  file.managed:
    - name: /etc/salt/minion.d/mine.conf
    - contents: |
        mine_functions:
          ipv4:
            - mine_function: grains.get
            - key: ipv4
    - user: root
    - group: root
    - mode: "0644"

update_mine:
  cmd.run:
    - name: salt-call mine.update
    - require:
      - file: ensure_mine_config
