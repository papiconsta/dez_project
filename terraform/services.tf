
# Enable required GCP APIs before creating any resources
# Without these, Terraform will fail with 403 "API not enabled" errors

resource "google_project_service" "iam" {
  service            = "iam.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "compute" {
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "storage" {
  service            = "storage.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "bigquery" {
  service            = "bigquery.googleapis.com"
  disable_on_destroy = false
}

# ── Service Accounts ─────────────────────────────────────────────────────────

resource "google_service_account" "vm1_extract" {
  account_id   = "vm1-extract-sa"
  display_name = "VM1 Extract - writes raw data to GCS"
  depends_on   = [google_project_service.iam]
}

resource "google_service_account" "vm2_load" {
  account_id   = "vm2-load-sa"
  display_name = "VM2 Load - reads GCS, writes to BigQuery"
  depends_on   = [google_project_service.iam]
}

resource "google_service_account" "vm3_airflow" {
  account_id   = "vm3-airflow-sa"
  display_name = "VM3 Airflow Orchestrator - triggers and monitors pipeline"
  depends_on   = [google_project_service.iam]
}
