# GCE Coolify Module - Main Configuration
# Deploys Coolify on Google Compute Engine with persistent data disk

# Only create static IP if not using an existing one
resource "google_compute_address" "coolify" {
  count  = var.existing_ip_address == "" ? 1 : 0
  name   = "${var.instance_name}-ip"
  region = var.region

  lifecycle {
    prevent_destroy = true
  }
}

locals {
  external_ip = var.existing_ip_address != "" ? var.existing_ip_address : google_compute_address.coolify[0].address
}

resource "google_compute_firewall" "coolify" {
  name    = "${var.instance_name}-allow-web"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "4200", "8000", "6001", "6002"]
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

# Mount data disk if it has a filesystem
DATA_DISK="/dev/disk/by-id/google-data-disk"
if [ -e "$DATA_DISK" ]; then
  if blkid "$DATA_DISK" > /dev/null 2>&1; then
    echo "Data disk has filesystem, mounting to /data"
    mkdir -p /data
    if ! mountpoint -q /data; then
      mount "$DATA_DISK" /data
      # Ensure fstab entry exists
      if ! grep -q "google-data-disk" /etc/fstab; then
        echo "$DATA_DISK /data ext4 defaults,nofail 0 2" >> /etc/fstab
      fi
    fi
  else
    echo "Data disk exists but no filesystem - formatting..."
    mkfs.ext4 -F "$DATA_DISK"
    mkdir -p /data
    mount "$DATA_DISK" /data
    echo "$DATA_DISK /data ext4 defaults,nofail 0 2" >> /etc/fstab
  fi
fi

# Check if Docker is installed (needed for all boot paths)
if ! command -v docker &> /dev/null; then
  echo "Docker not installed - installing..."
  curl -fsSL https://get.docker.com | sh
  systemctl enable docker
  systemctl start docker
  echo "Docker installed"
fi

%{if var.gcs_bucket_name != ""}
# Install gcsfuse if not present
if ! command -v gcsfuse &> /dev/null; then
  echo "Installing gcsfuse..."
  curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --batch --yes --dearmor -o /usr/share/keyrings/gcsfuse.gpg
  echo "deb [signed-by=/usr/share/keyrings/gcsfuse.gpg] https://packages.cloud.google.com/apt gcsfuse-noble main" | tee /etc/apt/sources.list.d/gcsfuse.list
  apt-get update
  apt-get install -y gcsfuse
  sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf
fi

# Mount GCS bucket if not mounted
if ! mountpoint -q ${var.gcs_mount_path}; then
  mkdir -p ${var.gcs_mount_path}
  gcsfuse --implicit-dirs -o allow_other --file-mode=777 --dir-mode=777 ${var.gcs_bucket_name} ${var.gcs_mount_path} || echo "GCS mount failed"
  # Ensure fstab entry exists
  if ! grep -q "${var.gcs_mount_path}" /etc/fstab; then
    echo "${var.gcs_bucket_name} ${var.gcs_mount_path} gcsfuse rw,nofail,_netdev,implicit_dirs,allow_other,file_mode=777,dir_mode=777" >> /etc/fstab
  fi
fi
%{endif}

# Function to restore from backup
restore_from_backup() {
  echo "Starting recovery from backup..."

  # Find latest backup
  BACKUP_DIR="/data/coolify/backups"
  if [ ! -d "$BACKUP_DIR" ]; then
    echo "No backup directory found - cannot recover"
    return 1
  fi

  LATEST_BACKUP=$(find "$BACKUP_DIR" \( -name "*.sql" -o -name "*.dump" -o -name "*.dmp" \) 2>/dev/null | sort -r | head -1)
  if [ -z "$LATEST_BACKUP" ]; then
    echo "No backup files found - cannot recover"
    return 1
  fi

  echo "Found backup: $LATEST_BACKUP"

  # Wait for postgres to be ready
  echo "Waiting for postgres..."
  for i in {1..30}; do
    if docker exec coolify-db pg_isready -U coolify &>/dev/null; then
      break
    fi
    sleep 2
  done

  # Restore the backup
  echo "Restoring database..."
  if [[ "$LATEST_BACKUP" == *.dump ]] || [[ "$LATEST_BACKUP" == *.dmp ]]; then
    docker exec -i coolify-db pg_restore --verbose --clean --no-acl --no-owner -U coolify -d coolify < "$LATEST_BACKUP" || true
  else
    docker exec -i coolify-db psql -U coolify -d coolify < "$LATEST_BACKUP" || true
  fi

  echo "Database restored from backup"
  return 0
}

# Determine boot path
if [ -f /data/coolify/source/.env ]; then
  echo "Found existing Coolify config on data disk"

  # Check if postgres volume exists and has data
  if docker volume inspect coolify-db &>/dev/null; then
    # Check if volume has actual postgres data
    if docker run --rm -v coolify-db:/data alpine ls /data/pg_wal &>/dev/null 2>&1; then
      echo "=== QUICK BOOT PATH ==="
      echo "Postgres volume intact - starting containers"
      cd /data/coolify/source
      docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
      echo "Quick boot completed at $(date)"
      exit 0
    fi
  fi

  echo "=== RECOVERY BOOT PATH ==="
  echo "Config exists but postgres volume is empty/missing"

  # Save the existing .env (contains APP_KEY)
  cp /data/coolify/source/.env /data/coolify/source/.env.preserved
  echo "Preserved existing .env with APP_KEY"

  # Run fresh Coolify install
  echo "Running fresh Coolify install..."
  curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash

  # Stop containers for recovery
  cd /data/coolify/source
  docker compose -f docker-compose.yml -f docker-compose.prod.yml down

  # Restore the preserved .env (with original APP_KEY)
  cp /data/coolify/source/.env.preserved /data/coolify/source/.env
  echo "Restored original .env with APP_KEY"

  # Start containers with correct APP_KEY
  docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

  # Wait for containers
  sleep 15

  # Try to restore from backup
  if restore_from_backup; then
    echo "Recovery from backup successful"
    # Restart to apply restored data
    docker compose -f docker-compose.yml -f docker-compose.prod.yml restart
    # Sync SSH keys from restored database to filesystem
    docker exec coolify php artisan db:seed --class=PopulateSshKeysDirectorySeeder --force || true
    # Add restored SSH key to authorized_keys (backup has different key than fresh install)
    for keyfile in /data/coolify/ssh/keys/ssh_key@*; do
      if [ -f "$keyfile" ]; then
        ssh-keygen -y -f "$keyfile" >> /root/.ssh/authorized_keys 2>/dev/null || true
      fi
    done
    sort -u /root/.ssh/authorized_keys -o /root/.ssh/authorized_keys
    echo "SSH keys synced to authorized_keys"
  else
    echo "No backup to restore - Coolify will need manual setup"
  fi

  echo "Recovery boot completed at $(date)"
  exit 0
fi

# Fresh install path
echo "=== FRESH INSTALL PATH ==="
echo "First boot - installing Coolify"
curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash

echo "Coolify installation completed at $(date)"
SCRIPT
}

# Boot disk (ephemeral - can be recreated, data is on separate disk)
resource "google_compute_disk" "coolify" {
  name  = "${var.instance_name}-disk"
  type  = "pd-ssd"
  zone  = var.zone
  size  = var.disk_size
  image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"

  lifecycle {
    ignore_changes = [image, labels, snapshot]
  }
}

# Persistent data disk for /data (survives instance deletion)
resource "google_compute_disk" "coolify_data" {
  name = "${var.instance_name}-data"
  type = "pd-ssd"
  zone = var.zone
  size = var.data_disk_size

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [labels, snapshot]
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

  attached_disk {
    source      = google_compute_disk.coolify_data.self_link
    device_name = "data-disk"
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = local.external_ip
    }
  }

  metadata_startup_script = local.startup_script

  service_account {
    scopes = ["cloud-platform"]
  }

  lifecycle {
    ignore_changes = [boot_disk, metadata_startup_script]
  }
}
