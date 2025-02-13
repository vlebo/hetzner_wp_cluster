{% set config = salt['pillar.get']('senec:gluster') %}

install_gluster_client:
  pkg.installed:
    - name: glusterfs-client

ensure_mount_directory:
  file.directory:
    - name: {{ config.mount_path }}
    - mode: "755"
    - makedirs: True

mount_gluster_volume:
  mount.mounted:
    - name: {{ config.mount_path }}
    - device: web1:/{{ config.volume_name }}
    - fstype: glusterfs
    - opts: defaults,_netdev
    - dump: 0
    - pass_num: 0
    - persist: True
