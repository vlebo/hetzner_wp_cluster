variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type        = string
  sensitive   = true
}

variable "lb_type" {
  description = "Load balancer type"
  type        = string
  default     = "lb11"
}

variable "lb_name" {
  description = "Name of the load balancer"
  type        = string
}

variable "location" {
  description = "Location of the load balancer"
  type        = string
}

variable "network_id" {
  description = "ID of the network to attach the load balancer to"
  type        = string
}

variable "lb_ip" {
  description = "IP address for the load balancer in the network"
  type        = string
}

variable "target_server_id" {
  description = "ID of the target server"
  type        = string
}

variable "private_key_path" {
  description = "Path to SSL certificate private key file"
  type        = string
  default     = null # Make it optional for initial setup
}

variable "certificate_path" {
  description = "Path to SSL certificate file"
  type        = string
  default     = null # Make it optional for initial setup
}

variable "domain_names" {
  description = "List of domain names for the certificate"
  type        = list(string)
}