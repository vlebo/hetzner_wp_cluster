{% set config = salt['pillar.get']('senec:common') %}

create_mount_dir:
  file.directory:
    - name: {{ config.mounted_volumes_path }}
    - user: {{ config.web_user }}
    - group: {{ config.web_user }}
    - mode: "755"
    - makedirs: True

format_volume:
  cmd.run:
    - name: |
        if ! blkid /dev/sdb; then
          mkfs.ext4 /dev/sdb
        fi
    - unless: blkid /dev/sdb

mount_volume:
  mount.mounted:
    - name: {{ config.mounted_volumes_path }}
    - device: /dev/sdb
    - fstype: ext4
    - opts: defaults
    - dump: 0
    - pass_num: 2
    - persist: True

set_permissions:
  cmd.run:
    - name: chown -R {{ config.web_user }}:{{ config.web_user }} {{ config.mounted_volumes_path }}
    - require:
      - file: create_mount_dir
      - mount: mount_volume
