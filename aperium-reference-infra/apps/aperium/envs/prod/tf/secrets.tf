locals {
  app_secrets = var.enable_secret_manager ? toset(var.app_secret_ids) : toset([])
}

resource "google_secret_manager_secret" "app" {
  for_each = local.app_secrets

  secret_id = each.value

  replication {
    auto {}
  }

  depends_on = [google_project_service.required["secretmanager.googleapis.com"]]
}
