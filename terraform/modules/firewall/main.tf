resource "hcloud_firewall" "firewall" {
  name = var.firewall_name

  dynamic "rule" {
    for_each = var.firewall_rules
    content {
      direction  = lookup(rule.value, "direction", "in")  # Default to inbound
      protocol   = rule.value.protocol
      port       = rule.value.port
      source_ips = rule.value.source_ips
    }
  }

  apply_to {
    label_selector = var.server_label
  }
}
