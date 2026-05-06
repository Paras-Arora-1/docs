resource "google_bigquery_dataset" "aperium_tabular" {
  count = var.enable_bigquery ? 1 : 0

  dataset_id    = var.bigquery_dataset_id
  project       = var.gcp_project_id
  location      = var.bigquery_location
  description   = "Managed Aperium tabular upload/query dataset"
  friendly_name = "Aperium Tabular"

  default_table_expiration_ms = 2592000000

  labels = {
    app   = "aperium"
    owner = "data-ai"
  }

  depends_on = [google_project_service.required["bigquery.googleapis.com"]]
}

resource "google_bigquery_dataset_iam_member" "aperium_tabular_data_editor" {
  count = var.enable_bigquery ? 1 : 0

  project    = var.gcp_project_id
  dataset_id = google_bigquery_dataset.aperium_tabular[0].dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${google_service_account.aperium_runtime.email}"
}
