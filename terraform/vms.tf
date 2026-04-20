# Allow SSH on port 22 for all VMs
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["extract-vm", "load-vm", "airflow-vm"]
}

# Allow Airflow UI on port 8080 for VM3 only
resource "google_compute_firewall" "allow_airflow_ui" {
  name    = "allow-airflow-ui"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["airflow-vm"]
}

resource "google_compute_instance" "vm1_extract" {
  name         = "vm1-ingestion-hub"
  machine_type = "e2-standard-2"
  zone         = local.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 20
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  service_account {
    email  = google_service_account.vm1_extract.email
    scopes = ["cloud-platform"]
  }

  tags = ["extract-vm"]
}

resource "google_compute_instance" "vm2_load" {
  name         = "vm2-processing-engine"
  machine_type = "e2-standard-4"
  zone         = local.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 50
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  service_account {
    email  = google_service_account.vm2_load.email
    scopes = ["cloud-platform"]
  }

  tags = ["load-vm"]
}

resource "google_compute_instance" "vm3_airflow" {
  name         = "vm3-orchestrator"
  machine_type = "e2-standard-2"
  zone         = local.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 30
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  service_account {
    email  = google_service_account.vm3_airflow.email
    scopes = ["cloud-platform"]
  }

  tags = ["airflow-vm"]


  ## this is automatical scripts that when the vm will
  ## be setteled they will run .
  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y python3-pip python3-venv
    python3 -m venv /opt/airflow-venv
    /opt/airflow-venv/bin/pip install apache-airflow
    echo "source /opt/airflow-venv/bin/activate" >> /root/.bashrc
  EOF
}
