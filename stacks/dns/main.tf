# DNS Stack - Main Configuration
# Manages all GoDaddy DNS records

terraform {
  required_version = ">= 1.0"
  required_providers {
    godaddy = {
      source  = "n3integration/godaddy"
      version = "~> 1.9"
    }
  }
}

provider "godaddy" {
  key    = var.godaddy_api_key
  secret = var.godaddy_api_secret
}
