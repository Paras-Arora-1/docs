terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "< 4"
    }
  }
}

data "google_client_config" "default" {}

data "google_container_cluster" "default" {
  name = var.gke_cluster_name
}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.default.endpoint}"
  token                  = data.google_client_config.default.access_token
  client_certificate     = base64decode(data.google_container_cluster.default.master_auth[0].client_certificate)
  client_key             = base64decode(data.google_container_cluster.default.master_auth[0].client_key)
  cluster_ca_certificate = base64decode(data.google_container_cluster.default.master_auth[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes = {
    host                   = "https://${data.google_container_cluster.default.endpoint}"
    token                  = data.google_client_config.default.access_token
    client_certificate     = base64decode(data.google_container_cluster.default.master_auth[0].client_certificate)
    client_key             = base64decode(data.google_container_cluster.default.master_auth[0].client_key)
    cluster_ca_certificate = base64decode(data.google_container_cluster.default.master_auth[0].cluster_ca_certificate)
  }
}

resource "kubernetes_namespace_v1" "argo_cd" {
  metadata {
    name = "argo-cd"
  }
}

resource "kubernetes_secret_v1" "repo_key" {
  metadata {
    name      = "aperium-gcp-infra"
    namespace = kubernetes_namespace_v1.argo_cd.metadata[0].name
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type                    = "git"
    url                     = var.git_repo_url
    githubAppID             = var.github_app_id
    githubAppInstallationID = var.github_app_installation_id
    githubAppPrivateKey     = var.github_app_private_key
  }

  type = "Opaque"
}

resource "helm_release" "argo_cd" {
  name          = "argo-cd"
  repository    = "https://argoproj.github.io/argo-helm"
  chart         = "argo-cd"
  namespace     = kubernetes_namespace_v1.argo_cd.metadata[0].name
  version       = var.argocd_helm_chart_version
  wait_for_jobs = true

  values = [
    templatefile("${path.module}/argo-bootstrap-values.yaml", {
      dnsDomain          = trim(var.dns_domain, ".")
      ssoEnabled         = var.sso_enabled
      ssoSignonUrl       = trimspace(var.sso_signon_url)
      ssoCaCert          = trimspace(var.sso_ca_cert)
      ingressEnabled     = var.ingress_enabled
      argoOktaPolicy     = var.argo_okta_policy
      argocdAdminEnabled = var.argocd_admin_enabled
    })
  ]

  depends_on = [
    kubernetes_namespace_v1.argo_cd,
    kubernetes_secret_v1.repo_key,
  ]
}

resource "helm_release" "argo_resources" {
  name          = "argo-resources"
  chart         = "${path.module}/argo-resources"
  namespace     = kubernetes_namespace_v1.argo_cd.metadata[0].name
  wait_for_jobs = true

  values = [
    file(var.argo_resources_values_file)
  ]

  depends_on = [helm_release.argo_cd]
}
