senec:
  common:
    mounted_volumes_path: /var/www/
    web_user: www-data
    web_servers: ['web1', 'web2', 'web3']
    domain: wordpress-vl.senecops.com
    email: admin@mywebsite.com
  gluster:
    client_pkg: glusterfs-client
    server_pkg: glusterfs-server
    service_name: glusterd
    peers: ['web2', 'web3']
    bricks_path: /var/www/gluster
    volume_name: wordpress-vol
    mount_path: /var/www/senec
  mariadb:
    db_servers: ['web1', 'web2', 'web3']
    pkg_name: mariadb-server
    service_name: mariadb
    root_password: "SuperSecureRootPassword123!"
    senec_root_user: senec_root
    senec_root_password: "SuperSecureRootPassword123!"
    backup_dir: /var/backups/wordpress
  wordpress:
    install_dir: /var/www/senec
    site_title: Senec WP task from Vedran
    wp_dir: /var/www/senec/wordpress
    db_name: "wordpress"
    db_user: "wordpressuser"
    db_password: "wp123"
    db_host: "LB"
    db_port: 3306
    admin_user: senec_admin
    admin_password: StrongPassword123
    admin_email: admin@example.com 
