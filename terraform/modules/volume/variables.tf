variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type        = string
  sensitive   = true
}

variable "server_name" {  
  description = "Name of the server this volume is attached to"
  type        = string
}

variable "server_id" {
  description = "ID of the server this volume is attached to"
  type        = number
}

variable "volume_size" {
  description = "Size of the shared volume in GB"
  type        = number
}

variable "location" {
  description = "Hetzner Cloud location"
  type        = string
}
