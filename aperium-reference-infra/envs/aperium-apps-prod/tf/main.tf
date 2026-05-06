terraform {
  cloud {
    organization = "YOUR_TFC_ORG"

    workspaces {
      name = "YOUR_SHARED_ENV_WORKSPACE"
    }
  }

  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }

  required_version = "~> 1.14.0"
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = var.gcp_zone
}

module "base_resources" {
  source = "../../../tf/modules/base_resources"

  gcp_project_id = var.gcp_project_id
  gcp_region     = var.gcp_region
  env_name       = var.env_name
  network_cidr   = var.network_cidr
  service_cidr   = var.service_cidr
  pod_cidr       = var.pod_cidr
  nat_ip_count   = var.nat_ip_count
}

module "argocd" {
  source = "../../../tf/modules/argocd"

  gke_cluster_name           = module.base_resources.gke_cluster_name
  dns_domain                 = var.dns_domains[0]
  git_repo_url               = var.git_repo_url
  github_app_id              = var.github_app_id
  github_app_installation_id = var.github_app_installation_id
  github_app_private_key     = var.github_app_private_key
  argo_resources_values_file = "${path.module}/argo-resources.yaml"

  ingress_enabled      = var.argocd_ingress_enabled
  argocd_admin_enabled = var.argocd_admin_enabled
  sso_enabled          = var.argo_sso_enabled
  sso_signon_url       = var.argo_sso_signon_url
  sso_ca_cert          = var.argo_sso_ca_cert
  argo_okta_policy     = var.argo_okta_policy
}
