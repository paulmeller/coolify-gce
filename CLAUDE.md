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
- **Boot Disk**: Persistent SSD (50GB) with `prevent_destroy = true` - survives terraform destroy
- **Static IP**: Preserved with `prevent_destroy = true`
- **Startup Script**: Idempotent - detects existing installation and takes quick boot path
- **State Storage**: GCS bucket (`context-prompt-terraform-state`)
- **CI/CD**: GitHub Actions triggers `terraform apply` on push to main
- **GCS FUSE**: Optional bucket mounting at `/mnt/gcs-storage`

## Important Concepts

### Idempotent Startup Script

The startup script in `main.tf` has two paths:

1. **First boot**: Full installation (~5-10 min)
   - Installs Docker and Coolify
   - Installs gcsfuse (if GCS bucket configured)
   - Mounts GCS bucket
   - Creates `/data/coolify/.env` marker

2. **Quick boot**: Detected via `/data/coolify/.env` (~10 sec)
   - Starts Docker
   - Mounts GCS bucket (if configured)
   - **Preserves Docker containers and services**

### Resource Persistence

Both disk and static IP have `prevent_destroy = true`:
- `google_compute_disk.coolify` - Boot disk persists across terraform destroy
- `google_compute_address.coolify` - Static IP persists across terraform destroy

To destroy only the instance (preserving disk and IP):
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
| `disk_size` | Boot disk (GB) | `50` |
| `instance_name` | Instance name | `coolify-server` |
| `gcs_bucket_name` | GCS bucket to mount | `""` (disabled) |
| `gcs_mount_path` | Mount path for GCS | `/mnt/gcs-storage` |

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

Installed at `/usr/local/bin/coolify` (v1.4.0)

```bash
# SSH to server
gcloud compute ssh coolify-server --zone=us-central1-a

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

```bash
# Add context
coolify context add local http://localhost:8000 '<api-token>' --default
```

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
