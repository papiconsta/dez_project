# Data Engineering Project - GCP Infrastructure
# Provisions: VMs (Extract, Load, Airflow), GCS bucket, BigQuery, per-VM service accounts

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.8.0"
    }
  }
}

variable "service_account_key" {
  description = "secrets/dataengineeringproject-493216-cbbaffd3fb01.json"
  type        = string
}


locals {
  project = "dataengineeringproject-493216"
  region  = "europe-west1"
  zone    = "europe-west1-b"
}

provider "google" {
  credentials = file(var.service_account_key)
  project     = local.project
  region      = local.region
  zone        = local.zone
}


# ── Outputs ──────────────────────────────────────────────────────────────────
# this is something like print() functions.


output "gcs_bucket_name" {
  value = google_storage_bucket.raw_zone.name
}

output "vm1_external_ip" {
  value = google_compute_instance.vm1_extract.network_interface[0].access_config[0].nat_ip
}

output "vm2_external_ip" {
  value = google_compute_instance.vm2_load.network_interface[0].access_config[0].nat_ip
}

output "vm3_airflow_ip" {
  value       = google_compute_instance.vm3_airflow.network_interface[0].access_config[0].nat_ip
  description = "SSH into this VM to access Airflow"
}
