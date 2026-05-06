variable "gke_cluster_name" {
  type        = string
  description = "Name of the GKE cluster where ArgoCD is installed."
}

variable "dns_domain" {
  type        = string
  description = "DNS domain used for ArgoCD service (must include trailing dot in env var, will be trimmed)."
}

variable "git_repo_url" {
  type        = string
  description = "Git-compatible URL for Argo to watch this repository."
}

variable "github_app_id" {
  type        = string
  description = "GitHub App ID used by ArgoCD repository credentials secret."
}

variable "github_app_installation_id" {
  type        = string
  description = "GitHub App installation ID for the repository access grant."
}

variable "github_app_private_key" {
  type        = string
  description = "GitHub App private key PEM used by ArgoCD repository credentials secret."
  sensitive   = true
}

variable "argo_resources_values_file" {
  type        = string
  description = "Path to values file for the local argo-resources chart."
}

variable "ingress_enabled" {
  type        = bool
  default     = true
  description = "Enable GKE-managed ingress for ArgoCD server."
}

variable "argocd_admin_enabled" {
  type        = bool
  default     = true
  description = "Enable local ArgoCD admin account (recommended true until SSO is configured)."
}

variable "sso_enabled" {
  type        = bool
  default     = false
  description = "Enable SSO connector configuration in ArgoCD."
}

variable "sso_signon_url" {
  type        = string
  default     = ""
  description = "SSO signon URL (required when sso_enabled=true)."
}

variable "sso_ca_cert" {
  type        = string
  default     = ""
  description = "SSO CA cert (base64 or PEM string expected by Argo Dex connector)."
}

variable "argo_okta_policy" {
  type        = string
  description = "ArgoCD policy.csv content for group to role mapping."
  default     = <<EOT
g, "Engineering Admins", role:admin
EOT
}

variable "argocd_helm_chart_version" {
  type        = string
  default     = "8.5.9"
  description = "ArgoCD Helm chart version."
}
