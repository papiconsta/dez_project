resource "google_storage_bucket" "raw_zone" {
  name          = "${local.project}-raw-zone"
  location      = local.region
  force_destroy               = false
  uniform_bucket_level_access = true

  lifecycle_rule {
    condition { age = 30 }
    action    { type = "Delete" }
  }
}

# VM1 can write to GCS
resource "google_storage_bucket_iam_member" "vm1_gcs_write" {
  bucket = google_storage_bucket.raw_zone.name
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:${google_service_account.vm1_extract.email}"
}

# VM2 can read from GCS
resource "google_storage_bucket_iam_member" "vm2_gcs_read" {
  bucket = google_storage_bucket.raw_zone.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.vm2_load.email}"
}