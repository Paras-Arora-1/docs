data "google_project" "current" {
  project_id = var.gcp_project_id
}

# Autopilot nodes run as the project's default Compute Engine service account
# unless a custom node SA is configured. Grant it GAR pull access so workloads
# can pull private images from Artifact Registry.
resource "google_project_iam_member" "gke_nodes_artifact_registry_reader" {
  project = var.gcp_project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${data.google_project.current.number}-compute@developer.gserviceaccount.com"
}
