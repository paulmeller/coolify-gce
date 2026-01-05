# CLAUDE.md

This file provides context for Claude Code when working with this repository.

## Project Overview

Terraform configuration for deploying [Coolify](https://coolify.io) on Google Compute Engine with CI/CD via GitHub Actions.

## Key Files

| File | Purpose |
|------|---------|
| `main.tf` | Main Terraform configuration with all resources and startup script |
| `.github/workflows/terraform.yml` | GitHub Actions workflow for auto-deploy |
| `terraform.tfvars` | Local variables (gitignored) |
| `terraform.tfvars.example` | Example variables template |

## Architecture

- **GCE Instance**: `coolify-server` (e2-medium) running Ubuntu 24.04 LTS
- **Boot Disk**: Ephemeral SSD (20GB) - can be recreated, OS only
- **Data Disk**: Persistent SSD for `/data` with `prevent_destroy = true` - survives terraform destroy
- **Static IP**: Can use existing reserved IP or create new (with `prevent_destroy = true`)
- **Startup Script**: Idempotent - mounts data disk, detects existing installation
- **State Storage**: GCS bucket (`context-prompt-terraform-state`)
- **CI/CD**: GitHub Actions triggers `terraform apply` on push to main
- **GCS FUSE**: Optional bucket mounting at `/mnt/gcs-storage`

## Important Concepts

### Idempotent Startup Script

The startup script in `main.tf` has three boot paths:

1. **Fresh Install**: No `/data/coolify/source/.env` exists (~5-10 min)
   - Formats data disk if needed, mounts to `/data`
   - Installs Docker and Coolify
   - Installs gcsfuse (if GCS bucket configured)

2. **Quick Boot**: `.env` exists AND postgres Docker volume has data (~10 sec)
   - Mounts data disk to `/data`
   - Starts existing Coolify containers
   - **Preserves everything** - used for normal reboots

3. **Recovery Boot**: `.env` exists BUT postgres volume is empty/missing (~5-10 min)
   - Preserves existing `.env` (contains APP_KEY)
   - Runs fresh Coolify install
   - Restores original `.env` with APP_KEY
   - Restores database from `/data/coolify/backups/` if available
   - Syncs SSH keys from filesystem
   - **Used after `terraform destroy/apply`**

### Data Persistence Strategy

- **Boot disk**: Ephemeral - Coolify app + postgres Docker volume
- **Data disk `/data`**: Persistent - config, SSH keys, backups, user apps (n8n)

After `terraform destroy/apply`, the recovery boot path automatically:
1. Detects preserved config on data disk
2. Reinstalls Coolify with same APP_KEY
3. Restores database from backup

**Important**: Enable Coolify's built-in backups (Settings > Backup) for full recovery support.

### Resource Persistence

- `google_compute_disk.coolify` - Boot disk (ephemeral, no prevent_destroy)
- `google_compute_disk.coolify_data` - Data disk with `prevent_destroy = true`
- `google_compute_address.coolify` - Static IP with `prevent_destroy = true` (if created)

To destroy only the instance (preserving disks and IP):
```bash
terraform destroy -target=google_compute_instance.coolify -target=google_compute_firewall.coolify
```

### GCS FUSE (Optional)

Mount a GCS bucket for persistent storage:

```hcl
# terraform.tfvars
gcs_bucket_name = "your-bucket-name"
gcs_mount_path  = "/mnt/gcs-storage"  # default
```

The startup script:
- Installs gcsfuse on first boot
- Enables `allow_other` in fuse.conf
- Mounts with `--implicit-dirs -o allow_other --file-mode=777 --dir-mode=777`
- Adds to fstab with `nofail,_netdev` for persistent mounting

### Terraform Template Syntax

In the `locals` startup script block:
- `%{if var.gcs_bucket_name != ""}` → Terraform conditional
- `${var.gcs_mount_path}` → Terraform variable interpolation
- `$(date)` → Bash command substitution (no escaping needed in locals)

## Firewall Ports

| Port | Purpose |
|------|---------|
| 22 | SSH |
| 80 | HTTP (Traefik) |
| 443 | HTTPS (Traefik) |
| 8000 | Coolify UI |
| 6001-6002 | Coolify realtime service |

## Terraform Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `project_id` | GCP Project ID | *required* |
| `region` | GCP Region | `us-central1` |
| `zone` | GCP Zone | `us-central1-a` |
| `machine_type` | Instance type | `e2-medium` |
| `disk_size` | Boot disk (GB) | `20` |
| `data_disk_size` | Data disk for /data (GB) | `50` |
| `instance_name` | Instance name | `coolify-server` |
| `gcs_bucket_name` | GCS bucket to mount | `""` (disabled) |
| `gcs_mount_path` | Mount path for GCS | `/mnt/gcs-storage` |
| `existing_ip_name` | Name of existing reserved IP | `""` |
| `existing_ip_address` | Existing static IP to use | `""` (creates new) |

## Terraform Outputs

| Output | Description |
|--------|-------------|
| `external_ip` | Server IP address |
| `coolify_url` | Admin panel URL (port 8000) |
| `ssh_command` | SSH access command |

## Common Tasks

### Deploy from scratch
```bash
terraform init
terraform apply
```

### Test destroy/apply cycle (preserves disk/IP)
```bash
terraform destroy -target=google_compute_instance.coolify -target=google_compute_firewall.coolify
terraform apply
```

### Check services after deploy
```bash
gcloud compute ssh coolify-server --zone=us-central1-a --command="sudo docker ps"
```

### View startup log
```bash
gcloud compute ssh coolify-server --zone=us-central1-a --command="sudo tail -f /var/log/coolify-install.log"
```

### Check GCS mount
```bash
gcloud compute ssh coolify-server --zone=us-central1-a --command="mountpoint /mnt/gcs-storage && ls /mnt/gcs-storage"
```

### Upgrade Coolify
```bash
gcloud compute ssh coolify-server --zone=us-central1-a --command="sudo /data/coolify/source/upgrade.sh"
```

### Trigger CI/CD manually
```bash
git commit --allow-empty -m "Trigger CI/CD" && git push
```

## Coolify CLI

Install locally from GitHub releases:

```bash
# Download and install
curl -fsSL https://github.com/coollabsio/coolify-cli/releases/download/v1.4.0/coolify-cli-darwin-arm64.tar.gz | tar xz
mv coolify ~/bin/  # or /usr/local/bin/

# Configure context (get API token from Coolify UI > Settings > API)
coolify context add coolify http://35.184.84.184:8000 '<api-token>' --default
```

### Common Commands

```bash
# List apps
coolify app list

# List servers
coolify server list

# Restart an app
coolify app restart <uuid>

# View logs
coolify app logs <uuid>
```

### CLI Configuration

Config stored at: `~/.config/coolify/config.json`

## GitHub Secrets Required

| Secret | Description |
|--------|-------------|
| `GCP_CREDENTIALS` | Service account JSON key |
| `TF_VAR_PROJECT_ID` | GCP project ID |
| `TF_VAR_GCS_BUCKET_NAME` | GCS bucket for gcsfuse mount (optional, leave empty to skip) |

## Service Account Permissions

The `terraform-ci` service account needs:
- `roles/compute.admin` - Manage GCE resources
- `roles/storage.admin` - Manage GCS state bucket and gcsfuse access
- `roles/iam.serviceAccountUser` on default compute SA - Create instances

## Gotchas

1. **Terraform version**: Requires >= 1.0
2. **fstab duplication**: Script removes existing mount line before appending
3. **Service account permissions**: CI needs `serviceAccountUser` role on compute SA
4. **State migration**: Run `terraform init -reconfigure` when changing backend
5. **prevent_destroy**: Must be removed from main.tf before full terraform destroy
6. **Coolify port**: UI is on port 8000, not 80/443
7. **Realtime service**: Requires ports 6001-6002 open in firewall
8. **Coolify CLI volumes**: Does not support volume management - must use UI
9. **sslip.io**: Rate-limited for Let's Encrypt - use custom domains
10. **n8n permissions**: Runs as uid 1000 - host directories need `chown 1000:1000`
