# Compute Stack - Backend Configuration

terraform {
  backend "gcs" {
    bucket = "context-prompt-terraform-state"
    prefix = "compute"
  }
}
