output "lb_id" {
  description = "ID of the load balancer"
  value       = hcloud_load_balancer.lb.id
}

output "lb_ipv4" {
  description = "IPv4 address of the load balancer"
  value       = hcloud_load_balancer.lb.ipv4
}

output "network_id" {
  description = "ID of the network the load balancer is attached to"
  value       = hcloud_load_balancer_network.lb_network.network_id
}