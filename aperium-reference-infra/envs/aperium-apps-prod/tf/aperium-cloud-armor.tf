locals {
  # Cloud Armor supports at most 10 CIDRs per src_ip_ranges block.
  aperium_cloud_armor_allowlist_chunks = [
    for start in range(0, length(var.odoo_cloud_armor_allowed_cidrs), 10) :
    slice(
      var.odoo_cloud_armor_allowed_cidrs,
      start,
      min(start + 10, length(var.odoo_cloud_armor_allowed_cidrs)),
    )
  ]
}

resource "google_compute_security_policy" "aperium_allowlist" {
  count = var.enable_aperium_cloud_armor_policy ? 1 : 0

  name        = var.aperium_cloud_armor_policy_name
  description = "Cloud Armor allowlist policy for Aperium Gateway access."

  dynamic "rule" {
    for_each = local.aperium_cloud_armor_allowlist_chunks

    content {
      priority    = 1000 + (rule.key * 10)
      description = "Allow trusted CIDRs batch ${rule.key + 1}"
      action      = "allow"

      match {
        versioned_expr = "SRC_IPS_V1"

        config {
          src_ip_ranges = rule.value
        }
      }
    }
  }

  rule {
    priority    = 2147483647
    description = "Deny all other traffic"
    action      = "deny(403)"

    match {
      versioned_expr = "SRC_IPS_V1"

      config {
        src_ip_ranges = ["*"]
      }
    }
  }

  depends_on = [module.base_resources]
}
