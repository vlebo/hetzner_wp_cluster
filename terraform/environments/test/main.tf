module "network" {
  source        = "../../modules/network"
  hcloud_token  = var.hcloud_token
  network_name  = var.network_name
  network_cidr  = var.network_cidr
}

module "servers" {
  source          = "../../modules/server"
  hcloud_token    = var.hcloud_token
  server_names    = keys(var.servers)
  servers         = var.servers
  ssh_public_keys = var.ssh_public_keys
  server_ips      = {
    for name, config in var.servers : name => config.ip
  }
  server_type     = var.server_type
  image           = var.image
  location        = var.location
  network_id      = module.network.network_id
}


module "volumes" {
  source      = "../../modules/volume"
  for_each    = {
    for name, config in var.servers : name => config
    if config.role == "web"  # Only create volumes for web servers
  }
  
  hcloud_token = var.hcloud_token
  server_name  = each.key
  server_id    = module.servers.server_ids[each.key]
  volume_size  = var.volume_size
  location     = var.location
}

module "firewall" {
  source        = "../../modules/firewall"
  hcloud_token  = var.hcloud_token
  firewall_name = "test-firewall"
  server_label  = "name=LB"
  firewall_rules = var.firewall_rules
}

module "loadbalancer" {
  source           = "../../modules/loadbalancer"
  hcloud_token     = var.hcloud_token
  lb_name          = "load-balancer-1"
  location         = var.location
  network_id       = module.network.network_id
  lb_ip           = "10.0.0.10"
  target_server_id = module.servers.server_ids["LB"]
  domain_names     = ["wordpress-vl.senecops.com"]
  private_key_path = "./certs/privkey.pem"
  certificate_path = "./certs/fullchain.pem"
}