resource "google_service_account" "aperium_runtime" {
  account_id   = var.gcp_service_account_id
  display_name = "Aperium Runtime"
}

locals {
  workload_identity_members = [
    for k8s_spec in var.k8s_service_accounts :
    "serviceAccount:${var.gcp_project_id}.svc.id.goog[${k8s_spec}]"
  ]
}

resource "google_project_iam_member" "aperium_runtime_project_roles" {
  for_each = toset(var.app_project_roles)

  project = var.gcp_project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.aperium_runtime.email}"
}

resource "google_service_account_iam_binding" "workload_identity_member" {
  service_account_id = google_service_account.aperium_runtime.name
  role               = "roles/iam.workloadIdentityUser"

  members = local.workload_identity_members
}
