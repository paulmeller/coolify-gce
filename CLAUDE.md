# CLAUDE.md

This file provides context for Claude Code when working with this repository.

## Project Overview

Enterprise-ready Terraform configuration for managing:
- **Compute Stack**: Coolify on Google Compute Engine
- **DNS Stack**: GoDaddy DNS records for 32 domains

Both stacks use remote state in GCS and have independent CI/CD pipelines.

## Project Structure

```
coolify-gce/
├── modules/                          # Reusable Terraform modules
│   └── gce-coolify/                  # GCE instance + Coolify deployment
│       ├── main.tf                   # Resources: disks, firewall, instance
│       ├── variables.tf              # Input variables
│       └── outputs.tf                # Output values
│
├── stacks/                           # Deployable infrastructure stacks
│   ├── compute/                      # GCE + Coolify stack
│   │   ├── main.tf                   # Uses modules/gce-coolify
│   │   ├── backend.tf                # GCS: prefix = "compute"
│   │   ├── variables.tf              # Stack variables
│   │   └── terraform.tfvars.example  # Example config
│   │
│   └── dns/                          # GoDaddy DNS stack
│       ├── main.tf                   # Provider config
│       ├── domains.tf                # All 32 domain records
│       ├── backend.tf                # GCS: prefix = "dns"
│       ├── variables.tf              # Stack variables
│       └── terraform.tfvars.example  # Example config
│
├── utils/                            # Helper scripts (gitignored)
│   ├── fetch_dns.sh                  # Fetch DNS records from GoDaddy API
│   ├── dns_records.json              # Cached DNS records
│   └── generate_terraform.py         # Generate domains.tf from JSON
│
├── .github/workflows/
│   ├── terraform-compute.yml         # CI/CD for compute stack
│   ├── terraform-dns.yml             # CI/CD for DNS stack
│   └── terraform-reusable.yml        # Shared workflow template
│
└── CLAUDE.md                         # This file
```

## State Management

All Terraform state is stored in GCS bucket `context-prompt-terraform-state`:

| Stack | State Prefix | Resources |
|-------|--------------|-----------|
| Compute | `compute` | 4 (disks, firewall, instance) |
| DNS | `dns` | 32 (domain records) |

## Architecture

### Compute Stack
- **GCE Instance**: `coolify-server` (e2-medium) running Ubuntu 24.04 LTS
- **Boot Disk**: Ephemeral SSD (20GB) - can be recreated, OS only
- **Data Disk**: Persistent SSD for `/data` with `prevent_destroy = true`
- **Static IP**: Reserved IP with `prevent_destroy = true`
- **Startup Script**: Idempotent - handles fresh install, quick boot, and recovery

### DNS Stack
- **32 domains** managed via GoDaddy API
- **Record types**: A, CNAME, MX, NS, TXT
- **Provider**: n3integration/godaddy ~> 1.9

### Email Configuration
Domains with Google Workspace MX records:
- `contextprompt.com`
- `borderproof.com`

MX records point to Google's mail servers (aspmx.l.google.com, etc.)

## Important Concepts

### Idempotent Startup Script

The startup script in `modules/gce-coolify/main.tf` has three boot paths:

1. **Fresh Install**: No `/data/coolify/source/.env` exists
   - Formats data disk, mounts to `/data`
   - Installs Docker and Coolify
   - Installs gcsfuse (if configured)

2. **Quick Boot**: `.env` exists AND postgres volume has data
   - Mounts data disk to `/data`
   - Starts existing Coolify containers

3. **Recovery Boot**: `.env` exists BUT postgres volume empty
   - Preserves existing `.env` with APP_KEY
   - Runs fresh Coolify install
   - Restores database from backup if available

### Data Persistence Strategy

- **Boot disk**: Ephemeral - Coolify app + postgres Docker volume
- **Data disk `/data`**: Persistent - config, SSH keys, backups, user apps

**Important**: Enable Coolify's built-in backups (Settings > Backup) for full recovery support.

## Firewall Ports

| Port | Purpose |
|------|---------|
| 22 | SSH |
| 80 | HTTP (Traefik) |
| 443 | HTTPS (Traefik) |
| 8000 | Coolify UI |
| 6001-6002 | Coolify realtime service |

## CI/CD Workflows

### Compute Stack (`terraform-compute.yml`)
Triggers on changes to:
- `stacks/compute/**`
- `modules/gce-coolify/**`

### DNS Stack (`terraform-dns.yml`)
Triggers on changes to:
- `stacks/dns/**`

Both workflows:
- Run `terraform plan` on PRs
- Run `terraform apply` on push to main

## Common Tasks

### Deploy Compute Stack
```bash
cd stacks/compute
terraform init
terraform apply
```

### Deploy DNS Stack
```bash
cd stacks/dns
terraform init
terraform apply
```

### Test compute destroy/apply (preserves disk/IP)
```bash
cd stacks/compute
terraform destroy -target=module.coolify.google_compute_instance.coolify \
                  -target=module.coolify.google_compute_firewall.coolify
terraform apply
```

### Check Coolify services
```bash
gcloud compute ssh coolify-server --zone=us-central1-a --command="sudo docker ps"
```

### View startup log
```bash
gcloud compute ssh coolify-server --zone=us-central1-a --command="sudo tail -f /var/log/coolify-install.log"
```

### Upgrade Coolify
```bash
gcloud compute ssh coolify-server --zone=us-central1-a --command="sudo /data/coolify/source/upgrade.sh"
```

### Regenerate DNS Terraform
```bash
cd utils
./fetch_dns.sh              # Fetch latest records from GoDaddy
python generate_terraform.py # Generate stacks/dns/domains.tf
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
coolify app list          # List apps
coolify server list       # List servers
coolify app restart <uuid> # Restart an app
coolify app logs <uuid>   # View logs
```

## GitHub Secrets Required

| Secret | Stack | Description |
|--------|-------|-------------|
| `GCP_CREDENTIALS` | Both | Service account JSON key |
| `TF_VAR_PROJECT_ID` | Compute | GCP project ID |
| `TF_VAR_GCS_BUCKET_NAME` | Compute | GCS bucket for gcsfuse (optional) |
| `GODADDY_API_KEY` | DNS | GoDaddy API key |
| `GODADDY_API_SECRET` | DNS | GoDaddy API secret |

## Service Account Permissions

The `terraform-ci` service account needs:
- `roles/compute.admin` - Manage GCE resources
- `roles/storage.admin` - Manage GCS state bucket and gcsfuse access
- `roles/iam.serviceAccountUser` on default compute SA

## Terraform Variables

### Compute Stack

| Variable | Description | Default |
|----------|-------------|---------|
| `project_id` | GCP Project ID | *required* |
| `region` | GCP Region | `us-central1` |
| `zone` | GCP Zone | `us-central1-a` |
| `machine_type` | Instance type | `e2-medium` |
| `disk_size` | Boot disk (GB) | `20` |
| `data_disk_size` | Data disk (GB) | `50` |
| `instance_name` | Instance name | `coolify-server` |
| `gcs_bucket_name` | GCS bucket to mount | `""` |
| `gcs_mount_path` | Mount path for GCS | `/mnt/gcs-storage` |
| `existing_ip_address` | Use existing IP | `""` |

### DNS Stack

| Variable | Description |
|----------|-------------|
| `godaddy_api_key` | GoDaddy API key |
| `godaddy_api_secret` | GoDaddy API secret |

## Gotchas

1. **Terraform version**: Requires >= 1.0
2. **prevent_destroy**: Remove from module before full terraform destroy
3. **Coolify port**: UI is on port 8000, not 80/443
4. **Realtime service**: Requires ports 6001-6002 open
5. **Coolify CLI volumes**: Does not support volume management - use UI
6. **sslip.io**: Rate-limited for Let's Encrypt - use custom domains
7. **n8n permissions**: Runs as uid 1000 - directories need `chown 1000:1000`
8. **DNS changes**: GoDaddy API has rate limits - batch changes carefully
9. **Utils scripts**: Located in `utils/` and gitignored - contain API credentials
