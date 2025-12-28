# CLAUDE.md

This file provides context for Claude Code when working with this repository.

## Project Overview

Terraform configuration for deploying [Easypanel](https://easypanel.io) on Google Compute Engine with CI/CD via GitHub Actions.

## Key Files

| File | Purpose |
|------|---------|
| `main.tf` | Main Terraform configuration with all resources and startup script |
| `.github/workflows/terraform.yml` | GitHub Actions workflow for auto-deploy |
| `terraform.tfvars` | Local variables (gitignored) |
| `terraform.tfvars.example` | Example variables template |

## Architecture

- **GCE Instance**: Runs Docker + Easypanel on Ubuntu 24.04 LTS
- **Boot Disk**: Persistent SSD with `auto_delete = false` (survives instance deletion)
- **Startup Script**: Idempotent - detects existing installation and takes quick boot path
- **State Storage**: GCS bucket (`context-prompt-terraform-state`)
- **CI/CD**: GitHub Actions triggers `terraform apply` on push to main

## Important Concepts

### Idempotent Startup Script

The startup script in `main.tf` (lines 216-396) has two paths:

1. **First boot**: Full installation (~5-10 min)
   - Installs Docker, Easypanel, gcsfuse, Tailscale
   - Creates `/etc/easypanel/data/data.mdb` marker

2. **Quick boot**: Detected via marker file (~10 sec)
   - Starts Docker
   - Mounts GCS bucket
   - Connects Tailscale
   - **Preserves Docker Swarm services**

### Disk Persistence

The boot disk is preserved across `terraform destroy`:
- `auto_delete = false` on the boot disk
- `data.external.disk_check` detects if disk exists
- Existing disk is reused on next `terraform apply`

### Terraform Escaping

In `templatestring()` function:
- `$$` → literal `$` (for bash variables like `$(date)`)
- `%%{` → literal `%{` (for Terraform conditionals in script)
- `$${var}` → literal `${var}` (for bash variable expansion)

## Common Tasks

### Test destroy/apply cycle
```bash
terraform destroy -auto-approve
terraform apply -auto-approve
```

### Check services after deploy
```bash
gcloud compute ssh easypanel-server --zone=us-central1-a --command="sudo docker service ls"
```

### View startup log
```bash
gcloud compute ssh easypanel-server --zone=us-central1-a --command="sudo cat /var/log/easypanel-install.log"
```

### Trigger CI/CD manually
```bash
git commit --allow-empty -m "Trigger CI/CD" && git push
```

## GitHub Secrets Required

| Secret | Description |
|--------|-------------|
| `GCP_CREDENTIALS` | Service account JSON key |
| `TF_VAR_PROJECT_ID` | GCP project ID |
| `TF_VAR_EXISTING_IP_NAME` | Static IP name |
| `TF_VAR_EXISTING_IP_ADDRESS` | Static IP address |
| `TF_VAR_GCS_BUCKET_NAME` | GCS bucket for gcsfuse mount |
| `TF_VAR_TAILSCALE_AUTH_KEY` | Tailscale auth key (optional) |

## Service Account Permissions

The `terraform-ci` service account needs:
- `roles/compute.admin` - Manage GCE resources
- `roles/storage.admin` - Manage GCS state bucket
- `roles/iam.serviceAccountUser` on default compute SA - Create instances

## Security

- Only ports 22, 80, 443 are open (GCP firewall + ufw)
- All services accessed via Traefik on port 80/443 with domain routing
- No direct access to internal ports (3000, 5678, etc.)

## Gotchas

1. **Terraform version**: Requires >= 1.9 for `templatestring()` function
2. **fstab duplication**: Script checks before appending GCS mount to prevent duplicates
3. **Service account permissions**: CI needs `serviceAccountUser` role on compute SA
4. **State migration**: Run `terraform init -migrate-state` when enabling GCS backend
