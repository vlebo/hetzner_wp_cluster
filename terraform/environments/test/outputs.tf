output "server_ips" {
  description = "List of all server names and their assigned IPs"
  value       = module.servers.server_ips
}

output "load_balancer_ip" {
  value = module.servers.lb_public_ipv4
}