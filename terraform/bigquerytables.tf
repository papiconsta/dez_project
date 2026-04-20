resource "google_bigquery_dataset" "staging" {
  dataset_id = "staging"
  location   = local.region
}

resource "google_bigquery_dataset" "warehouse" {
  dataset_id = "warehouse"
  location  = local.region
}

# VM2 can write to BigQuery staging
resource "google_bigquery_dataset_iam_member" "vm2_bq_write" {
  dataset_id = google_bigquery_dataset.staging.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${google_service_account.vm2_load.email}"
}

# Airflow can read/write both datasets (for orchestration)
resource "google_bigquery_dataset_iam_member" "airflow_bq_staging" {
  dataset_id = google_bigquery_dataset.staging.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${google_service_account.vm3_airflow.email}"
}

resource "google_bigquery_dataset_iam_member" "airflow_bq_warehouse" {
  dataset_id = google_bigquery_dataset.warehouse.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${google_service_account.vm3_airflow.email}"
}