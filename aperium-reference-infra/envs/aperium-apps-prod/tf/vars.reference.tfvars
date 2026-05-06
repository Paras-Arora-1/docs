# Reference snapshot from the extracted Aperium prod-style environment. Copy values intentionally; do not auto-load this file in a live workspace.
gcp_project_id = "aperium-apps-prod"
gcp_region     = "us-central1"
gcp_zone       = "us-central1-a"

env_name     = "prod"
network_cidr = "10.205.0.0/16"
service_cidr = "172.27.0.0/20"
pod_cidr     = "172.28.0.0/20"
nat_ip_count = 1

dns_domains = [
  "apps.aperium.com.",
]

git_repo_url               = "https://github.com/aperium-ai/gcp-infra.git"
github_app_id              = "2886372"
github_app_installation_id = "110731358"

argocd_ingress_enabled = false
argocd_admin_enabled   = true
argo_sso_enabled       = false
