
resource "hcloud_load_balancer" "lb" {
  load_balancer_type = var.lb_type
  name              = var.lb_name
  location          = var.location
  
  lifecycle {
    ignore_changes = [
      load_balancer_type,
      location
    ]
  }
}

# Attach load balancer to network
resource "hcloud_load_balancer_network" "lb_network" {
  load_balancer_id = hcloud_load_balancer.lb.id
  network_id       = var.network_id
  ip              = var.lb_ip
}

# Add target servers
resource "hcloud_load_balancer_target" "lb_target" {
  type             = "server"
  load_balancer_id = hcloud_load_balancer.lb.id
  server_id        = var.target_server_id
}

# Upload certificate
resource "hcloud_uploaded_certificate" "lb_cert" {
  count       = var.private_key_path != null && var.certificate_path != null ? 1 : 0
  name        = "${var.lb_name}-cert"
  private_key = file(var.private_key_path)
  certificate = file(var.certificate_path)
}

# HTTPS service only
resource "hcloud_load_balancer_service" "https" {
  count            = var.private_key_path != null && var.certificate_path != null ? 1 : 0
  load_balancer_id = hcloud_load_balancer.lb.id
  protocol         = "https"
  listen_port      = 443
  destination_port = 80
  
  http {
    certificates  = [hcloud_uploaded_certificate.lb_cert[0].id]
  }
}
