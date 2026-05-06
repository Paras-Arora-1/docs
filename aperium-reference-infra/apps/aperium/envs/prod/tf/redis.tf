resource "google_redis_instance" "cache" {
  count = var.enable_redis ? 1 : 0

  name           = "aperium-cache"
  tier           = var.redis_tier
  memory_size_gb = var.redis_memory_size_gb
  region         = var.gcp_region
  redis_version  = var.redis_version

  authorized_network = var.gcp_network_path
  connect_mode       = "PRIVATE_SERVICE_ACCESS"

  labels = {
    environment = "prod"
    owner       = "data-ai"
  }

  depends_on = [google_project_service.required["redis.googleapis.com"]]
}
