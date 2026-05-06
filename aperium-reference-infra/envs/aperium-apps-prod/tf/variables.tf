variable "gcp_project_id" {
  description = "GCP project ID for shared prod environment resources."
  type        = string
}

variable "gcp_region" {
  description = "Default GCP region for shared resources."
  type        = string
  default     = "us-central1"
}

variable "gcp_zone" {
  description = "Default GCP zone for provider context."
  type        = string
  default     = "us-central1-c"
}

variable "env_name" {
  description = "Shared environment name used for network and cluster resources."
  type        = string
  default     = "prod"
}

variable "network_cidr" {
  description = "Primary subnet CIDR for the prod VPC."
  type        = string
}

variable "service_cidr" {
  description = "Secondary CIDR range for Kubernetes services."
  type        = string
}

variable "pod_cidr" {
  description = "Secondary CIDR range for Kubernetes pods."
  type        = string
}

variable "nat_ip_count" {
  description = "Number of static egress NAT IP addresses."
  type        = number
  default     = 1
}

variable "dns_domains" {
  description = "Public DNS zones to manage. Values must end with a trailing dot."
  type        = list(string)
}

variable "git_repo_url" {
  description = "Git-compatible URL for ArgoCD to watch."
  type        = string
  default     = "https://github.com/YOUR_ORG/aperium-reference-infra.git"
}

variable "github_app_id" {
  description = "GitHub App ID used by ArgoCD repository credentials."
  type        = string
}

variable "github_app_installation_id" {
  description = "GitHub App installation ID for this repository installation."
  type        = string
}

variable "github_app_private_key" {
  description = "GitHub App private key PEM. Set via Terraform Cloud sensitive variable."
  type        = string
  sensitive   = true
}

variable "argocd_ingress_enabled" {
  description = "Enable GKE-managed ingress for ArgoCD server."
  type        = bool
  default     = true
}

variable "argocd_admin_enabled" {
  description = "Enable local ArgoCD admin login (useful before SSO setup)."
  type        = bool
  default     = true
}

variable "argo_sso_enabled" {
  description = "Enable SSO (SAML) connector configuration for ArgoCD."
  type        = bool
  default     = false
}

variable "argo_sso_signon_url" {
  description = "SSO signon URL used by ArgoCD Dex connector."
  type        = string
  default     = ""
}

variable "argo_sso_ca_cert" {
  description = "SSO CA cert used by ArgoCD Dex connector."
  type        = string
  default     = ""
}

variable "argo_okta_policy" {
  description = "ArgoCD RBAC policy.csv entries for SSO group mapping."
  type        = string
  default     = <<EOT
g, "Engineering Admins", role:admin
EOT
}

variable "enable_aperium_cloud_armor_policy" {
  description = "Create a Cloud Armor allowlist policy for Aperium Gateway traffic."
  type        = bool
  default     = true
}

variable "aperium_cloud_armor_policy_name" {
  description = "Cloud Armor policy name attached to the Aperium backend/frontend Gateway backends."
  type        = string
  default     = "aperium-allowlist-policy"
}

variable "enable_odoo_cloud_armor_policy" {
  description = "Create a Cloud Armor allowlist policy for Odoo Gateway traffic. Kept for reference, but disabled by default in this extracted package."
  type        = bool
  default     = false
}

variable "odoo_cloud_armor_policy_name" {
  description = "Cloud Armor policy name attached to the Odoo GKE backend."
  type        = string
  default     = "odoo-allowlist-policy"
}

variable "odoo_cloud_armor_allowed_cidrs" {
  description = "Allowed source CIDRs for Odoo ingress. Seeded from Hillspire prod ingress-nginx default whitelist."
  type        = list(string)
  default = [
    "64.226.128.62/32",
    "12.124.157.254/32",
    "173.164.145.73/32",
    "12.55.124.254/32",
    "98.153.108.22/32",
    "158.106.213.34/32",
    "12.151.33.177/32",
    "50.209.134.38/32",
    "12.151.33.176/29",
    "50.209.134.32/29",
    "3.17.45.128/32",
    "216.158.144.130/32",
    "172.254.114.146/32",
    "172.125.239.151/32",
    "64.226.129.36/32",
    "95.67.123.30/32",
    "82.144.214.136/32",
    "20.237.169.184/32",
  ]
}
