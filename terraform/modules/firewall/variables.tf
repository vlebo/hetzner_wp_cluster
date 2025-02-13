variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type        = string
  sensitive   = true
}

variable "firewall_name" {
  description = "Name of the firewall"
  type        = string
}

variable "server_label" {
  description = "Label selector for the server to apply the firewall to"
  type        = string
}

variable "firewall_rules" {
  description = "List of firewall rules"
  type = list(object({
    protocol   = string
    port       = string
    source_ips = list(string)
    direction  = optional(string, "in")
  }))
}