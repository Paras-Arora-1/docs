resource "google_project_service" "secretmanager" {
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
}

# Shared secret container for HCP Terraform agent pool token payload.
resource "google_secret_manager_secret" "tfc_agent_config" {
  secret_id = "tfc-agent-config"

  replication {
    auto {}
  }

  depends_on = [google_project_service.secretmanager]
}
