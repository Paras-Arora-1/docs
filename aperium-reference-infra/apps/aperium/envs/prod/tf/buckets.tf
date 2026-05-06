resource "google_storage_bucket" "aperium" {
  count = var.enable_storage_bucket ? 1 : 0

  name                        = var.storage_bucket_name
  location                    = var.storage_bucket_location
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
}

resource "google_storage_bucket_iam_member" "aperium_object_admin" {
  count = var.enable_storage_bucket ? 1 : 0

  bucket = google_storage_bucket.aperium[0].name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.aperium_runtime.email}"
}
