{% set servers = salt['mine.get']('*', 'ipv4') %}

backup_hosts:
  file.copy:
    - name: /etc/hosts.bak
    - source: /etc/hosts
    - mode: "0644"

remove_old_entries:
  file.replace:
    - name: /etc/hosts
    - pattern: "^10\\.0\\.0\\.[0-9]+\\s+(web[0-9]+|LB)$"
    - repl: ""

update_hosts_file:
  file.append:
    - name: /etc/hosts
    - text: |
        {%- for server, ips in servers.items() %}
        {{ ips[0] }}  {{ server }}
        {%- endfor %}
    - require:
      - file: remove_old_entries
