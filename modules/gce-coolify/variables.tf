# GCE Coolify Module - Variables

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
  default     = 20
}

variable "data_disk_size" {
  description = "Data disk size in GB for /data"
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

variable "existing_ip_name" {
  description = "Name of existing reserved IP in GCP (for documentation)"
  type        = string
  default     = ""
}

variable "existing_ip_address" {
  description = "Existing static IP address to use (leave empty to create new)"
  type        = string
  default     = ""
}
