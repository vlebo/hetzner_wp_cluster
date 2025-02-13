resource "hcloud_volume" "shared_volume" {
  name      = "wordpress-shared-${var.server_name}"
  size      = var.volume_size
  location  = var.location
  format    = "ext4"
}

resource "hcloud_volume_attachment" "attach_volume" {
  server_id = var.server_id
  volume_id = hcloud_volume.shared_volume.id
  automount = true
}
