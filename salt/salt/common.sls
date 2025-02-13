remove_salt_repo:
  file.absent:
    - name: /etc/apt/sources.list.d/salt.list

install_common_pkgs:
  pkg.installed:
    - names:
      - vim
      - rsync