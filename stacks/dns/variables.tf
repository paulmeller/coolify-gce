# DNS Stack - Variables

variable "godaddy_api_key" {
  type        = string
  description = "GoDaddy API Key"
  sensitive   = true
}

variable "godaddy_api_secret" {
  type        = string
  description = "GoDaddy API Secret"
  sensitive   = true
}
