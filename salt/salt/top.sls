base:
  '*':
    - common
    - enable_salt_mine
    - update_hosts
  'web*':
    - mount_volumes
    - gluster.install
    - gluster.create_volume
    - gluster.mount
    - nginx.install
    - nginx.config
  'web1':
    - gluster.peer
  'LB':
    - haproxy.install
    - haproxy.letsencrypt
    - haproxy.config