# Coolify on Google Compute Engine
# Terraform Configuration

terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    bucket = "context-prompt-terraform-state"
    prefix = "coolify"
  }
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "us-central1-a"
}

variable "machine_type" {
  description = "GCE Machine Type"
  type        = string
  default     = "e2-medium"
}

variable "disk_size" {
  description = "Boot disk size in GB"
  type        = number
  default     = 50
}

variable "instance_name" {
  description = "Name for the GCE instance"
  type        = string
  default     = "coolify-server"
}

variable "gcs_bucket_name" {
  description = "GCS bucket to mount via gcsfuse (leave empty to skip)"
  type        = string
  default     = ""
}

variable "gcs_mount_path" {
  description = "Path to mount the GCS bucket"
  type        = string
  default     = "/mnt/gcs-storage"
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_address" "coolify" {
  name   = "${var.instance_name}-ip"
  region = var.region

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_firewall" "coolify" {
  name    = "${var.instance_name}-allow-web"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "8000", "6001", "6002"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["coolify"]
}

locals {
  startup_script = <<-SCRIPT
#!/bin/bash
set -e
exec > >(tee /var/log/coolify-install.log) 2>&1
echo "Startup script running at $(date)"

# Quick boot path if already installed
if [ -f /data/coolify/.env ]; then
  echo "Coolify already installed - quick boot"
  systemctl start docker || true
  sleep 5
%{if var.gcs_bucket_name != ""}
  # Remount GCS bucket if not mounted
  if ! mountpoint -q ${var.gcs_mount_path}; then
    mkdir -p ${var.gcs_mount_path}
    gcsfuse --implicit-dirs -o allow_other --file-mode=777 --dir-mode=777 ${var.gcs_bucket_name} ${var.gcs_mount_path} || echo "GCS mount failed"
  fi
%{endif}
  echo "Quick boot completed at $(date)"
  exit 0
fi

echo "First boot - installing Coolify"

%{if var.gcs_bucket_name != ""}
# Install and configure GCS FUSE
echo "Setting up GCS FUSE mount..."
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --batch --yes --dearmor -o /usr/share/keyrings/gcsfuse.gpg
echo "deb [signed-by=/usr/share/keyrings/gcsfuse.gpg] https://packages.cloud.google.com/apt gcsfuse-noble main" | tee /etc/apt/sources.list.d/gcsfuse.list
apt-get update
apt-get install -y gcsfuse

# Enable allow_other
sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf

# Mount bucket
mkdir -p ${var.gcs_mount_path}
gcsfuse --implicit-dirs -o allow_other --file-mode=777 --dir-mode=777 ${var.gcs_bucket_name} ${var.gcs_mount_path}

# Persist in fstab
sed -i "\|${var.gcs_mount_path}|d" /etc/fstab
echo "${var.gcs_bucket_name} ${var.gcs_mount_path} gcsfuse rw,nofail,_netdev,implicit_dirs,allow_other,file_mode=777,dir_mode=777" >> /etc/fstab
echo "GCS bucket ${var.gcs_bucket_name} mounted at ${var.gcs_mount_path}"
%{endif}

# Install Coolify
echo "Installing Coolify..."
curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash

echo "Coolify installation completed at $(date)"
SCRIPT
}

# Persistent boot disk (survives instance deletion)
resource "google_compute_disk" "coolify" {
  name = "${var.instance_name}-disk"
  type = "pd-ssd"
  zone = var.zone
  size = var.disk_size

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [image, labels, snapshot]
  }
}

resource "google_compute_instance" "coolify" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  tags = ["coolify"]

  boot_disk {
    source      = google_compute_disk.coolify.self_link
    auto_delete = false
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.coolify.address
    }
  }

  metadata_startup_script = local.startup_script

  service_account {
    scopes = ["cloud-platform"]
  }

  lifecycle {
    ignore_changes = [boot_disk]
  }
}

output "external_ip" {
  value = google_compute_address.coolify.address
}

output "coolify_url" {
  value = "http://${google_compute_address.coolify.address}:8000"
}

output "ssh_command" {
  value = "gcloud compute ssh ${var.instance_name} --zone=${var.zone}"
}
