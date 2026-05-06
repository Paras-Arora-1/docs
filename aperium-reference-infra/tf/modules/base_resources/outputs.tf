output "network_name" {
  description = "Shared VPC network name."
  value       = google_compute_network.default.name
}

output "network_self_link" {
  description = "Shared VPC network self link."
  value       = google_compute_network.default.self_link
}

output "subnetwork_name" {
  description = "Primary subnetwork name used by GKE."
  value       = google_compute_subnetwork.default.name
}

output "gke_cluster_name" {
  description = "Autopilot cluster name."
  value       = google_container_cluster.default.name
}

output "nat_ips" {
  description = "Allocated static egress IPs for Cloud NAT."
  value       = google_compute_address.nat_ip[*].address
}

output "platform_service_account_emails" {
  description = "Platform GSA emails keyed by controller name."
  value = {
    for key, sa in google_service_account.platform :
    key => sa.email
  }
}

output "external_dns_service_account" {
  description = "GSA email used by external-dns Workload Identity."
  value       = google_service_account.platform["external_dns"].email
}

output "cert_manager_service_account" {
  description = "GSA email used by cert-manager Workload Identity."
  value       = google_service_account.platform["cert_manager"].email
}

output "external_secrets_service_account" {
  description = "GSA email used by external-secrets Workload Identity."
  value       = google_service_account.platform["external_secrets"].email
}
