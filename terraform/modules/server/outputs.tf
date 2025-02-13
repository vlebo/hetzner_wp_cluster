output "server_ids" {
  description = "Map of server names to their IDs"
  value       = { for server in hcloud_server.server : server.name => server.id }
}

output "server_ips" {
  value = { for server_name, network in hcloud_server_network.server_network :
    server_name => network.ip }
}

output "server_labels" {
  description = "Map of server names to their labels"
  value       = { for k, v in hcloud_server.server : k => v.labels }
}