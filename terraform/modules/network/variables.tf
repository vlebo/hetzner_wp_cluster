variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type        = string
  sensitive   = true
}

variable "network_name" {
  description = "Hetzner network name"
  type        = string
}

variable "network_cidr" {
  description = "Network CIDR range"
  type        = string
}
