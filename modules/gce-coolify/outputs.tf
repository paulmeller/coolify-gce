# GCE Coolify Module - Outputs

output "external_ip" {
  description = "External IP address of the Coolify server"
  value       = local.external_ip
}

output "coolify_url" {
  description = "URL for the Coolify admin panel"
  value       = "http://${local.external_ip}:8000"
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "gcloud compute ssh ${var.instance_name} --zone=${var.zone}"
}

output "instance_name" {
  description = "Name of the GCE instance"
  value       = google_compute_instance.coolify.name
}

output "instance_self_link" {
  description = "Self link of the GCE instance"
  value       = google_compute_instance.coolify.self_link
}
