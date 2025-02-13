# Fetch all Floating IPs
data "hcloud_floating_ips" "all_floating_ips" {}

# Find the correct Floating IP by filtering with its known address
locals {
  existing_lb_ip = one([
    for ip in data.hcloud_floating_ips.all_floating_ips.floating_ips :
    ip if ip.ip_address == var.lb_floating_ip
  ])
}

# Register SSH keys in Hetzner Cloud
resource "hcloud_ssh_key" "my_keys" {
  count      = length(var.ssh_public_keys)
  name       = "key-${count.index}"
  public_key = var.ssh_public_keys[count.index]
}

resource "hcloud_server" "server" {
  for_each    = var.server_ips
  name        = each.key
  image       = var.image
  server_type = var.server_type
  location    = var.location
  ssh_keys    = hcloud_ssh_key.my_keys[*].name
  labels = {
    role = var.servers[each.key].role
    name = each.key
  }
  
  public_net {
    ipv4_enabled = var.servers[each.key].role == "lb"
  }
  user_data = templatefile("${path.module}/cloud-init.tpl", {
    floating_ip  = var.lb_floating_ip
    is_master    = var.servers[each.key].role == "lb" ? "true" : "false"
    master_ip    = var.server_ips["LB"]
  })
}

# Assign the Floating IP to the LB server
resource "hcloud_floating_ip_assignment" "assign_lb_ip" {
  floating_ip_id = local.existing_lb_ip.id
  server_id      = hcloud_server.server["LB"].id
  depends_on     = [hcloud_server.server]
}

resource "hcloud_server_network" "server_network" {
  for_each   = var.server_ips
  server_id  = hcloud_server.server[each.key].id
  network_id = var.network_id
  ip         = each.value
}
