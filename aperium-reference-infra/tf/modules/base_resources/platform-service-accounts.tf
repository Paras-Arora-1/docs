locals {
  platform_service_accounts = {
    external_dns = {
      account_id    = "external-dns"
      display_name  = "External DNS"
      k8s_namespace = "external-dns"
      k8s_name      = "external-dns"
      project_roles = ["roles/dns.admin"]
    }
    cert_manager = {
      account_id    = "cert-manager"
      display_name  = "Cert Manager"
      k8s_namespace = "cert-manager"
      k8s_name      = "cert-manager"
      project_roles = ["roles/dns.admin"]
    }
    external_secrets = {
      account_id    = "external-secrets"
      display_name  = "External Secrets"
      k8s_namespace = "external-secrets"
      k8s_name      = "external-secrets"
      project_roles = ["roles/secretmanager.secretAccessor"]
    }
  }

  platform_project_role_bindings = merge([
    for sa_key, cfg in local.platform_service_accounts : {
      for role in cfg.project_roles :
      "${sa_key}-${replace(role, "/", "-")}" => {
        service_account_key = sa_key
        role                = role
      }
    }
  ]...)
}

resource "google_service_account" "platform" {
  for_each = local.platform_service_accounts

  account_id   = each.value.account_id
  display_name = each.value.display_name
}

resource "google_project_iam_member" "platform_project_roles" {
  for_each = local.platform_project_role_bindings

  project = var.gcp_project_id
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.platform[each.value.service_account_key].email}"
}

resource "google_service_account_iam_member" "platform_workload_identity_user" {
  for_each = local.platform_service_accounts

  service_account_id = google_service_account.platform[each.key].name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.gcp_project_id}.svc.id.goog[${each.value.k8s_namespace}/${each.value.k8s_name}]"

  depends_on = [google_container_cluster.default]
}

resource "google_service_account_iam_member" "platform_token_creator" {
  for_each = local.platform_service_accounts

  service_account_id = google_service_account.platform[each.key].name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${var.gcp_project_id}.svc.id.goog[${each.value.k8s_namespace}/${each.value.k8s_name}]"

  depends_on = [
    google_container_cluster.default,
    google_service_account_iam_member.platform_workload_identity_user,
  ]
}
