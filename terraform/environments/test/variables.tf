variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type        = string
}

variable "server_type" {
  description = "Hetzner Cloud server type"
  type        = string
}

variable "image" {
  description = "OS image"
  type        = string
}

variable "location" {
  description = "Datacenter location"
  type        = string
}

variable "volume_size" {
  description = "Size of the shared volume in GB"
  type        = number
}

variable "ssh_public_keys" {
  description = "List of SSH public keys"
  type        = list(string)
}

variable "servers" {
  description = "Map of server configurations"
  type = map(object({
    ip = string
    role = string  # "web" or "lb"
  }))
}

variable "network_name" {
  description = "Hetzner network name"
  type        = string
}

variable "network_cidr" {
  description = "Network CIDR range"
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