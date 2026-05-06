resource "google_container_cluster" "default" {
  name                     = var.env_name
  location                 = var.gcp_region
  enable_autopilot         = true
  enable_l4_ilb_subsetting = true

  network    = google_compute_network.default.id
  subnetwork = google_compute_subnetwork.default.id

  ip_allocation_policy {
    stack_type                    = "IPV4"
    services_secondary_range_name = google_compute_subnetwork.default.secondary_ip_range[0].range_name
    cluster_secondary_range_name  = google_compute_subnetwork.default.secondary_ip_range[1].range_name
  }

  private_cluster_config {
    enable_private_nodes = true
  }

  gateway_api_config {
    channel = "CHANNEL_STANDARD"
  }

  deletion_protection = false

  depends_on = [
    google_project_service.container,
    google_compute_subnetwork.default,
  ]
}
