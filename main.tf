# Easypanel on Google Compute Engine
# Terraform Configuration

terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # Remote state storage (for CI/CD)
  backend "gcs" {
    bucket = "context-prompt-terraform-state"
    prefix = "easypanel"
  }
}

# Variables
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
  description = "GCE Machine Type (minimum 2GB RAM recommended)"
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
  default     = "easypanel-server"
}

variable "existing_ip_name" {
  description = "Name of an existing static IP to use (leave empty to create new)"
  type        = string
  default     = ""
}

variable "existing_ip_address" {
  description = "Existing static IP address (required if existing_ip_name is set)"
  type        = string
  default     = ""
}


variable "admin_ip_ranges" {
  description = "IP ranges allowed to access Easypanel admin (port 3000). Use ['0.0.0.0/0'] for open access."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tailscale_auth_key" {
  description = "Tailscale auth key for joining the network (leave empty to skip Tailscale setup)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "disable_public_admin" {
  description = "Disable public access to port 3000 (use with Tailscale for private admin access)"
  type        = bool
  default     = false
}

variable "ollama_tailscale_host" {
  description = "Tailscale hostname or IP of your Ollama server (e.g., 'ollama' or '100.x.x.x')"
  type        = string
  default     = ""
}

variable "gcs_bucket_name" {
  description = "GCS bucket to mount via gcsfuse (leave empty to skip)"
  type        = string
  default     = ""
}

variable "gcs_mount_path" {
  description = "Path to mount the GCS bucket"
  type        = string
  default     = "/mnt/easypanel-storage"
}

# Provider Configuration
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Static External IP (only created if not using existing)
resource "google_compute_address" "easypanel_ip" {
  count  = var.existing_ip_name == "" ? 1 : 0
  name   = "${var.instance_name}-ip"
  region = var.region
}

# Check if boot disk already exists (for reuse after destroy/apply)
data "external" "disk_check" {
  program = ["bash", "-c", <<-EOF
    if gcloud compute disks describe ${var.instance_name}-boot --zone=${var.zone} --project=${var.project_id} &>/dev/null; then
      echo '{"exists": "true"}'
    else
      echo '{"exists": "false"}'
    fi
  EOF
  ]
}

# Reference existing disk if it exists
data "google_compute_disk" "existing_boot" {
  count   = data.external.disk_check.result.exists == "true" ? 1 : 0
  name    = "${var.instance_name}-boot"
  zone    = var.zone
  project = var.project_id
}

locals {
  external_ip    = var.existing_ip_name != "" ? var.existing_ip_address : google_compute_address.easypanel_ip[0].address
  disk_exists    = data.external.disk_check.result.exists == "true"
  boot_disk_link = local.disk_exists ? data.google_compute_disk.existing_boot[0].self_link : google_compute_disk.boot[0].self_link
}

# Boot disk (created only if it doesn't already exist)
resource "google_compute_disk" "boot" {
  count = local.disk_exists ? 0 : 1
  name  = "${var.instance_name}-boot"
  type  = "pd-ssd"
  zone  = var.zone
  size  = var.disk_size
  image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"

  labels = {
    app        = "easypanel"
    managed-by = "terraform"
  }

  lifecycle {
    prevent_destroy = false
    ignore_changes  = [image, labels]
  }
}

# Firewall Rules
resource "google_compute_firewall" "easypanel_http" {
  name    = "${var.instance_name}-allow-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["easypanel"]
}

resource "google_compute_firewall" "easypanel_https" {
  name    = "${var.instance_name}-allow-https"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["easypanel"]
}

resource "google_compute_firewall" "easypanel_admin" {
  count   = var.disable_public_admin ? 0 : 1
  name    = "${var.instance_name}-allow-admin"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["3000"]
  }

  source_ranges = var.admin_ip_ranges
  target_tags   = ["easypanel"]
}

resource "google_compute_firewall" "easypanel_n8n" {
  name    = "${var.instance_name}-allow-n8n"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["5678"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["easypanel"]
}

# Startup Script Template
locals {
  startup_script_template = <<-SCRIPT
#!/bin/bash
set -e

exec > >(tee /var/log/easypanel-install.log) 2>&1
echo "Startup script running at $$(date)"

# Check if Easypanel is already installed (subsequent boot with preserved disk)
if [ -f /etc/easypanel/data/data.mdb ]; then
  echo "Easypanel already installed - running quick boot sequence"

  # Ensure Docker is running
  systemctl start docker || true

  # Wait for Docker
  sleep 5

%%{ if gcs_bucket_name != "" ~}
  # Remount GCS bucket if not mounted
  if ! mountpoint -q $${gcs_mount_path}; then
    mkdir -p $${gcs_mount_path}
    gcsfuse --implicit-dirs -o allow_other --file-mode=777 --dir-mode=777 $${gcs_bucket_name} $${gcs_mount_path} || echo "GCS mount failed"
  fi
%%{ endif ~}

%%{ if tailscale_auth_key != "" ~}
  # Ensure Tailscale is connected
  tailscale up --accept-routes --accept-dns=true || true
%%{ endif ~}

  echo "Quick boot completed at $$(date)"
  exit 0
fi

echo "First boot - running full Easypanel installation"

# Update system
apt-get update
apt-get upgrade -y
apt-get install -y curl wget lsof fail2ban ufw

# Configure firewall
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
%%{ if tailscale_auth_key == "" ~}
ufw allow 3000/tcp
%%{ else ~}
ufw allow from 100.64.0.0/10 to any port 3000
%%{ endif ~}
ufw --force enable

systemctl enable fail2ban
systemctl start fail2ban

# Install Tailscale
curl -fsSL https://tailscale.com/install.sh | sh

%%{ if tailscale_auth_key != "" ~}
echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
echo 'net.ipv6.conf.all.forwarding = 1' >> /etc/sysctl.conf
sysctl -p

tailscale up --authkey=$${tailscale_auth_key} --ssh --accept-routes --accept-dns=true

TAILSCALE_IP=$$(tailscale ip -4)

iptables -t nat -A POSTROUTING -s 172.16.0.0/12 -o tailscale0 -j MASQUERADE
iptables -A FORWARD -i docker0 -o tailscale0 -j ACCEPT
iptables -A FORWARD -i tailscale0 -o docker0 -m state --state RELATED,ESTABLISHED -j ACCEPT

apt-get install -y iptables-persistent
netfilter-persistent save

cat > /etc/docker/daemon.json <<'DOCKER'
{
  "log-driver": "json-file",
  "log-opts": {"max-size": "10m", "max-file": "3"},
  "storage-driver": "overlay2",
  "dns": ["100.100.100.100", "8.8.8.8"]
}
DOCKER

%%{ if ollama_tailscale_host != "" ~}
echo "Testing Ollama connection to $${ollama_tailscale_host}..."
sleep 5
curl -s --connect-timeout 5 "http://$${ollama_tailscale_host}:11434/api/tags" && echo "✓ Ollama reachable" || echo "⚠ Ollama not reachable yet"
%%{ endif ~}

echo "Tailscale connected: $$TAILSCALE_IP"
%%{ endif ~}

# Kernel tuning
cat >> /etc/sysctl.conf <<'SYSCTL'
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_tw_reuse = 1
vm.swappiness = 10
SYSCTL
sysctl -p

# Install Docker
if ! command -v docker &> /dev/null; then
    curl -sSL https://get.docker.com | sh
    systemctl enable docker
    systemctl start docker
fi

%%{ if tailscale_auth_key == "" ~}
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<'DOCKER'
{
  "log-driver": "json-file",
  "log-opts": {"max-size": "10m", "max-file": "3"},
  "storage-driver": "overlay2"
}
DOCKER
%%{ endif ~}
systemctl restart docker

sleep 10
docker swarm leave --force 2>/dev/null || true

echo "Installing Easypanel..."
docker pull easypanel/easypanel:latest
docker run --rm -i \
  -v /etc/easypanel:/etc/easypanel \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  easypanel/easypanel setup

# Create /data directory for n8n and other services
mkdir -p /data
chmod 777 /data

%%{ if gcs_bucket_name != "" ~}
# Install and configure GCS FUSE (Ubuntu 24.04 noble)
echo "Setting up GCS FUSE mount..."
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --batch --yes --dearmor -o /usr/share/keyrings/gcsfuse.gpg
echo "deb [signed-by=/usr/share/keyrings/gcsfuse.gpg] https://packages.cloud.google.com/apt gcsfuse-noble main" | tee /etc/apt/sources.list.d/gcsfuse.list
apt-get update
apt-get install -y gcsfuse

# Enable allow_other support (required for -o allow_other to work)
sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf

# Create mount point and mount bucket
mkdir -p $${gcs_mount_path}
gcsfuse --implicit-dirs -o allow_other --file-mode=777 --dir-mode=777 $${gcs_bucket_name} $${gcs_mount_path}

# Make mount persistent across reboots
if ! grep -q "$${gcs_bucket_name}" /etc/fstab; then
  echo "$${gcs_bucket_name} $${gcs_mount_path} gcsfuse rw,implicit_dirs,allow_other,file_mode=777,dir_mode=777" >> /etc/fstab
fi

echo "GCS bucket $${gcs_bucket_name} mounted at $${gcs_mount_path}"
%%{ endif ~}

apt-get install -y unattended-upgrades
echo 'Unattended-Upgrade::Automatic-Reboot "false";' >> /etc/apt/apt.conf.d/50unattended-upgrades

cat > /etc/cron.daily/docker-cleanup <<'CRON'
#!/bin/bash
docker system prune -af --volumes --filter "until=168h"
CRON
chmod +x /etc/cron.daily/docker-cleanup

echo "Easypanel installation completed at $$(date)"
echo "Public IP: $$(curl -s ifconfig.me)"
%%{ if tailscale_auth_key != "" ~}
echo "Tailscale IP: $$(tailscale ip -4)"
%%{ endif ~}
SCRIPT
}

# GCE Instance
resource "google_compute_instance" "easypanel" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  tags = ["easypanel", "http-server", "https-server"]

  boot_disk {
    source      = local.boot_disk_link
    auto_delete = false
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = local.external_ip
    }
  }

  metadata = {
    startup-script = templatestring(local.startup_script_template, {
      tailscale_auth_key    = var.tailscale_auth_key
      ollama_tailscale_host = var.ollama_tailscale_host
      gcs_bucket_name       = var.gcs_bucket_name
      gcs_mount_path        = var.gcs_mount_path
    })
  }

  allow_stopping_for_update = true

  service_account {
    scopes = ["cloud-platform"]
  }

  labels = {
    app        = "easypanel"
    managed-by = "terraform"
  }

  lifecycle {
    # Prevent recreation when startup script changes (it only runs on first boot anyway)
    ignore_changes = [
      metadata["startup-script"],
      boot_disk, # Don't recreate if disk config changes
    ]
    # Uncomment to prevent accidental destruction:
    # prevent_destroy = true
  }
}

# Outputs
output "instance_name" {
  value = google_compute_instance.easypanel.name
}

output "external_ip" {
  value = local.external_ip
}

output "easypanel_url" {
  value = "http://${local.external_ip}:3000"
}

output "ssh_command" {
  value = "gcloud compute ssh ${google_compute_instance.easypanel.name} --zone=${var.zone}"
}

output "installation_log_command" {
  value = "gcloud compute ssh ${google_compute_instance.easypanel.name} --zone=${var.zone} --command='sudo tail -f /var/log/easypanel-install.log'"
}

output "disk_info" {
  value = local.disk_exists ? "Disk: ${var.instance_name}-boot (existing)" : "Disk: ${var.instance_name}-boot (created)"
}

output "tailscale_info" {
  value     = var.tailscale_auth_key != "" ? "Tailscale enabled" : "Tailscale not configured"
  sensitive = true
}

output "ollama_info" {
  value = var.ollama_tailscale_host != "" ? "OLLAMA_HOST=http://${var.ollama_tailscale_host}:11434" : "Ollama not configured"
}

output "gcs_mount_info" {
  value = var.gcs_bucket_name != "" ? "GCS bucket '${var.gcs_bucket_name}' mounted at ${var.gcs_mount_path}" : "GCS FUSE not configured"
}

# Snapshot schedule for backups
resource "google_compute_resource_policy" "daily_backup" {
  name   = "${var.instance_name}-daily-backup"
  region = var.region

  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time    = "03:00"
      }
    }
    retention_policy {
      max_retention_days    = 3
      on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
    }
    snapshot_properties {
      labels            = { backup = "daily" }
      storage_locations = [var.region]
    }
  }
}

resource "google_compute_disk_resource_policy_attachment" "backup_attachment" {
  name = google_compute_resource_policy.daily_backup.name
  disk = "${var.instance_name}-boot"
  zone = var.zone

  # Only attach after disk exists (either created or existing)
  depends_on = [google_compute_instance.easypanel]
}
