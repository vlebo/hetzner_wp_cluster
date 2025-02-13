output "server_ips" {
  description = "List of all server names and their assigned IPs"
  value       = module.servers.server_ips
}
