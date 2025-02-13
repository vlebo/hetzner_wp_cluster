output "firewall_id" {
  description = "The ID of the created firewall"
  value       = hcloud_firewall.firewall.id
}
