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
- **Tailscale**: Managed via Easypanel container (not host-level)

## Important Concepts

### Idempotent Startup Script

The startup script in `main.tf` has two paths:

1. **First boot**: Full installation (~5-10 min)
   - Installs Docker, Easypanel, gcsfuse
   - Configures firewall (ufw), fail2ban
   - Sets up journald log limits
   - Creates `/etc/easypanel/data/data.mdb` marker

2. **Quick boot**: Detected via marker file (~10 sec)
   - Starts Docker
   - Mounts GCS bucket
   - **Preserves Docker Swarm services**

### Disk Persistence

The boot disk is preserved across `terraform destroy`:
- `auto_delete = false` on the boot disk
- `data.external.disk_check` detects if disk exists
- Existing disk is reused on next `terraform apply`

### Tailscale (Container-Based)

Tailscale is NOT installed by Terraform. Instead, it's managed via Easypanel container:

```yaml
services:
  tailscale:
    image: tailscale/tailscale:latest
    network_mode: host
    privileged: true
    environment:
      TS_USERSPACE: "false"  # Creates tailscale0 on host
      TS_EXTRA_ARGS: --advertise-tags=tag:container --accept-routes --advertise-exit-node
```

Key points:
- `network_mode: host` + `TS_USERSPACE: "false"` = kernel TUN mode
- Creates `tailscale0` interface on host
- All containers get Tailscale access via host network
- Exit node requires approval in Tailscale admin console

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

### Check Tailscale from container
```bash
gcloud compute ssh easypanel-server --zone=us-central1-a --command='sudo docker exec $(sudo docker ps -q --filter name=tailscale) tailscale status'
```

### Check host has Tailscale access
```bash
gcloud compute ssh easypanel-server --zone=us-central1-a --command='ping -c 1 100.100.100.100'
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

## Service Account Permissions

The `terraform-ci` service account needs:
- `roles/compute.admin` - Manage GCE resources
- `roles/storage.admin` - Manage GCS state bucket
- `roles/iam.serviceAccountUser` on default compute SA - Create instances

## Security

- Only ports 22, 80, 443 are open (GCP firewall + ufw)
- All services accessed via Traefik on port 80/443 with domain routing
- No direct access to internal ports (3000, 5678, etc.)
- Journald logs limited to 100M / 7 days

## Gotchas

1. **Terraform version**: Requires >= 1.9 for `templatestring()` function
2. **fstab duplication**: Script checks before appending GCS mount to prevent duplicates
3. **Service account permissions**: CI needs `serviceAccountUser` role on compute SA
4. **State migration**: Run `terraform init -migrate-state` when enabling GCS backend
5. **Tailscale exit node**: Must be approved in Tailscale admin console after advertising
