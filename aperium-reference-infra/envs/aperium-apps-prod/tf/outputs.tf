output "public_nameservers_by_zone" {
  description = "Authoritative name servers for each managed public zone."
  value = {
    for zone, res in google_dns_managed_zone.public_zones :
    zone => res.name_servers
  }
}

output "delegation_ns_records" {
  description = "NS records to add at the parent DNS provider for delegation."
  value = {
    for zone, res in google_dns_managed_zone.public_zones :
    zone => [for ns in res.name_servers : "${zone} IN NS ${ns}"]
  }
}

output "network_name" {
  description = "Shared prod VPC network name."
  value       = module.base_resources.network_name
}

output "network_self_link" {
  description = "Shared prod VPC network self link."
  value       = module.base_resources.network_self_link
}

output "subnetwork_name" {
  description = "Shared prod subnetwork name."
  value       = module.base_resources.subnetwork_name
}

output "gke_cluster_name" {
  description = "Autopilot cluster name."
  value       = module.base_resources.gke_cluster_name
}

output "nat_ips" {
  description = "Static egress NAT IP addresses."
  value       = module.base_resources.nat_ips
}

output "platform_service_account_emails" {
  description = "Platform controller GSA emails keyed by controller name."
  value       = module.base_resources.platform_service_account_emails
}

output "external_dns_service_account" {
  description = "GSA email for external-dns Workload Identity."
  value       = module.base_resources.external_dns_service_account
}

output "cert_manager_service_account" {
  description = "GSA email for cert-manager Workload Identity."
  value       = module.base_resources.cert_manager_service_account
}

output "external_secrets_service_account" {
  description = "GSA email for external-secrets Workload Identity."
  value       = module.base_resources.external_secrets_service_account
}

output "argocd_namespace" {
  description = "ArgoCD namespace."
  value       = module.argocd.namespace
}

output "argocd_server_hostname" {
  description = "ArgoCD hostname."
  value       = module.argocd.server_hostname
}

output "aperium_cloud_armor_policy_name" {
  description = "Cloud Armor policy name used by Aperium backend/frontend policies."
  value       = try(google_compute_security_policy.aperium_allowlist[0].name, null)
}

output "aperium_cloud_armor_policy_self_link" {
  description = "Cloud Armor policy self link for Aperium backend/frontend policies."
  value       = try(google_compute_security_policy.aperium_allowlist[0].self_link, null)
}

output "odoo_cloud_armor_policy_name" {
  description = "Cloud Armor policy name used by Odoo backend policy."
  value       = try(google_compute_security_policy.odoo_allowlist[0].name, null)
}

output "odoo_cloud_armor_policy_self_link" {
  description = "Cloud Armor policy self link for Odoo backend policy."
  value       = try(google_compute_security_policy.odoo_allowlist[0].self_link, null)
}

output "tfc_agent_config_secret_id" {
  description = "Shared Secret Manager secret ID used for Terraform agent pool token configuration."
  value       = google_secret_manager_secret.tfc_agent_config.secret_id
}
