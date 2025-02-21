senec:
  env: test
  ssh_user: senec
  infrastructure:
    server_type: cx22
    location: nbg1
    volume_size: 10
    image: ubuntu-22.04
    lb_server_ip: PLACEHOLER_FOR_LB_IP
    network_name: test-network
    network_cidr: 10.0.0.0/24
    ssh_public_keys:
      - "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHrpasS2reXghKkRBRuhWBAMsbCKLBaJ6wlLd71I7bYy vlebo@fp"
      - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/7WVNHJg2ivaf5fah3WLlofZv7AS05472qgC5xirykVOs0ga3pQPLChiePpbYuztAVTc3J9RG7r5GuDLsag5GRXrTKjRomM+0sjGZRkymZOdF2jKACtiwWbA4adJYZ7zgAw0sh3TSuDlCxg8RDSjKaZkaBfkn6TRepT7XWrqBr9OiEFsN+DgW4eQqHxWLWCOZjjaEfQ3vrZ39XId/wgHSBKNv4YDM1Aag6FTVIkOQI2MLq/qCfvDGIRfECWZBIIngHx+AXJmEC/cwmHeRxgInvisRkfeuV6DlbHyXCgm5XCBzNaX4zZrN7NBcYgzFcHCqDgm3WO5/RhR513udEDZHb9UMyhtJQt8miJkcAZ8CLXmFB40R+PsKtdhD2AsHGN6xHKp5VH1BNJsiX4W4o3Y/nSytcnzF5NA0oOHmNNQbKDc+NKwAyhFIFX/701gRITIV2G7qWOQqKKryE+IGte8Bz+ehmPxA71dBRXHE2FFymeVTW8Z81QDBYTdapxXwvWnO4NHGGBlYwSa3phvkm53uOUTmBaFwKyR+8HSsfiJByTGDR2jqFUbvGygZmn8jgJc1V5MDssQud6Imxy3uV+eZN30H+MMQ704cjpGG+Pwak8J+2Ap3Fg4DC+nmTw2NwttL5UKLGcdB/N0Yly5tTOhAEV/XLLlfiyKuCEKWVE4Ibw=="
    server_ips:
      web1: 10.0.0.5
      web2: 10.0.0.2
      web3: 10.0.0.3
      LB: 10.0.0.4
    firewall_rules:
      - protocol: tcp
        port: "22"
        source_ips: ["0.0.0.0/0", "::/0"]
      - protocol: tcp
        port: "80"
        source_ips: ["0.0.0.0/0", "::/0"]
      - protocol: tcp
        port: "443"
        source_ips: ["0.0.0.0/0", "::/0"]
      - protocol: tcp
        port: "4505"
        source_ips: ["10.0.0.0/24"]
      - protocol: tcp
        port: "4506"
        source_ips: ["10.0.0.0/24"]
      - protocol: tcp
        port: "3306"
        source_ips: ["10.0.0.0/24"]
      - protocol: tcp
        port: "8404"
        source_ips: ["0.0.0.0/0"]
  common:
    mounted_volumes_path: /var/www/
    web_user: www-data
    web_servers: ['web1', 'web2', 'web3']
    domain: wordpress-vl.senecops.com
#    domain: wp.fpng.in
    email: admin@senecops.com
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
    root_password: "SANITIZED"
    senec_root_user: senec_root
    senec_root_password: "SANITIZED"
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
    admin_password: "SANITIZED"
    admin_email: admin@senecops.com
