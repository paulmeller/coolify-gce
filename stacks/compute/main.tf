# Compute Stack - Main Configuration
# Deploys Coolify on GCE using the gce-coolify module

terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

module "coolify" {
  source = "../../modules/gce-coolify"

  project_id          = var.project_id
  region              = var.region
  zone                = var.zone
  machine_type        = var.machine_type
  disk_size           = var.disk_size
  data_disk_size      = var.data_disk_size
  instance_name       = var.instance_name
  gcs_bucket_name     = var.gcs_bucket_name
  gcs_mount_path      = var.gcs_mount_path
  existing_ip_name    = var.existing_ip_name
  existing_ip_address = var.existing_ip_address
}

output "external_ip" {
  value = module.coolify.external_ip
}

output "coolify_url" {
  value = module.coolify.coolify_url
}

output "ssh_command" {
  value = module.coolify.ssh_command
}
