variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type        = string
  sensitive   = true
}

variable "server_names" {
  description = "List of server names"
  type        = list(string)
}

variable "server_ips" {
  description = "Predefined private IP addresses for the servers"
  type        = map(string)
}

variable "server_type" {
  description = "Hetzner Cloud server type"
  type        = string
}

variable "image" {
  description = "OS image for the servers"
  type        = string
}

variable "location" {
  description = "Hetzner Cloud location"
  type        = string
}

variable "network_id" {
  description = "Existing Hetzner network ID"
  type        = string
}

variable "lb_floating_ip" {
  description = "Existing Floating IP address for Load Balancer"
  type        = string
}

variable "ssh_public_keys" {
  description = "List of SSH public keys"
  type        = list(string)
}

variable "servers" {
  description = "Map of server configurations"
  type = map(object({
    ip = string
    role = string
  }))
}