# Install common packages
install_common_pkgs:
  salt.state:
    - tgt: '*'
    - sls:
      - common

# Enable Salt Mine on all servers
enable_salt_mine:
  salt.state:
    - tgt: '*'
    - sls:
      - enable_salt_mine

# Update Salt Mine on all servers
update_salt_mine:
  salt.function:
    - name: mine.update
    - tgt: '*'
    - require:
      - salt: enable_salt_mine

# Update /etc/hosts on all servers
update_hosts:
  salt.state:
    - tgt: '*'
    - sls:
      - update_hosts

# Mount volumes on all web servers
mount_volumes:
  salt.state:
    - tgt: 'web*'
    - sls:
      - mount_volumes

# Install GlusterFS on web servers
install_gluster:
  salt.state:
    - tgt: 'web*'
    - sls:
      - gluster.install

# Peer GlusterFS nodes (Only on web1)
gluster_peer:
  salt.state:
    - tgt: 'web1'
    - sls:
      - gluster.peer
    - require:
      - salt: install_gluster

# Create GlusterFS volume (Only on web1)
gluster_create_volume:
  salt.state:
    - tgt: 'web1'
    - sls:
      - gluster.create_volume
    - require:
      - salt: gluster_peer

# Mount GlusterFS volume on all web servers
gluster_mount:
  salt.state:
    - tgt: 'web*'
    - sls:
      - gluster.mount
    - require:
      - salt: gluster_create_volume

# Install MariaDB on web servers
install_mariadb:
  salt.state:
    - tgt: 'web*'
    - sls:
      - mariadb.install

# Configure firewall for MariaDB on web servers
configure_mariadb_firewall:
  salt.state:
    - tgt: 'web*'
    - sls:
      - mariadb.firewall
    - require:
      - salt: install_mariadb

# Set MariaDB root password on web1 server
set_mariadb_root_password:
  salt.state:
    - tgt: 'web1'
    - sls:
      - mariadb.secure_root
    - require:
      - salt: configure_mariadb_firewall

# Configure Galera clustering for MariaDB
configure_mariadb_galera:
  salt.state:
    - tgt: 'web*'
    - sls:
      - mariadb.galera
    - require:
      - salt: configure_mariadb_firewall

# Bootstrap MariaDB cluster (Only on web1)
bootstrap_mariadb:
  salt.state:
    - tgt: 'web*'
    - sls:
      - mariadb.bootstrap
    - require:
      - salt: configure_mariadb_galera

# Start MariaDB service on all web servers
start_mariadb_service:
  salt.state:
    - tgt: 'web*'
    - sls:
      - mariadb.service
    - require:
      - salt: bootstrap_mariadb

# Configure MariaDB backup
backup_mariadb:
  salt.state:
    - tgt: 'web1'
    - sls:
      - mariadb.backup
    - require:
      - salt: start_mariadb_service

# Generate SSL cert on LB server
generate_letsencrypt_cert:
  salt.state:
    - tgt: 'LB'
    - sls:
      - ssl
    - require:
      - salt: start_mariadb_service

# Install and configure HAproxy
install_and_configure_haproxy:
  salt.state:
    - tgt: 'LB'
    - sls:
      - haproxy
    - require:
      - salt: generate_letsencrypt_cert

# Download wordpress
download_wordpress:
  salt.state:
    - tgt: 'LB'
    - sls:
      - wordpress.download

# Install wordpress dependencies
install_wordpress_dependencies:
  salt.state:
    - tgt: 'web*'
    - sls:
      - wordpress.deps

# Install wordpress
install_wordpress:
  salt.state:
    - tgt: 'web1'
    - sls:
      - wordpress.install

# Configure wordpress
configure_wordpress:
  salt.state:
    - tgt: 'web1'
    - sls:
      - wordpress.config

# Create Wordpress database and user
create_wordpress_db_and_user:
  salt.state:
    - tgt: 'web1'
    - sls:
      - wordpress.db

#Install Wordpress CLI
install_wordpress_cli:
  salt.state:
    - tgt: 'web1'
    - sls:
      - wordpress.cli

# Finalize Wordpress installation
finialize_wordpress_installation:
  salt.state:
    - tgt: 'web1'
    - sls:
      - wordpress.finalize

# Install and configure nginx on all web servers
install_and_configure_nginx:
  salt.state:
    - tgt: 'web*'
    - sls:
      - nginx
    - require:
      - salt: configure_wordpress
