resource "google_project_service" "clouddns" {
  service            = "dns.googleapis.com"
  disable_on_destroy = false
}

resource "google_dns_managed_zone" "public_zones" {
  for_each = toset(var.dns_domains)

  name        = "public-${trim(replace(each.key, ".", "-"), "-")}"
  dns_name    = each.key
  description = "Public zone - ${each.key}"

  depends_on = [google_project_service.clouddns]
}
