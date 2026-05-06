resource "google_artifact_registry_repository" "aperium" {
  count = var.enable_artifact_registry ? 1 : 0

  repository_id = var.gar_repository_id
  description   = "Aperium app container images"
  format        = "DOCKER"

  depends_on = [google_project_service.required["artifactregistry.googleapis.com"]]
}
