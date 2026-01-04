# Coolify on Google Compute Engine (Terraform)

Deploy [Coolify](https://coolify.io) - an open-source, self-hostable Heroku/Netlify alternative - on Google Compute Engine using Terraform.

## Features

- **Automated Setup**: Docker and Coolify installed via startup script
- **Idempotent Boots**: Fast restarts (~10s) with service preservation across `terraform destroy/apply`
- **Separate Data Disk**: `/data` on dedicated persistent SSD (`prevent_destroy = true`)
- **Ephemeral Boot Disk**: OS-only, can be recreated (data safe on data disk)
- **Static IP**: Use existing reserved IP or create new persistent IP
- **GCS Storage**: Optional GCS bucket mounting via gcsfuse
- **CI/CD Ready**: GitHub Actions workflow for auto-deploy on push
- **Ubuntu 24.04 LTS**: Latest long-term support release

## Prerequisites

1. **Google Cloud SDK** installed and authenticated
   ```bash
   gcloud auth login
   gcloud auth application-default login
   ```

2. **Terraform** >= 1.0 installed
   ```bash
   # macOS
   brew install terraform

   # Ubuntu/Debian
   sudo apt-get install terraform
   ```

3. **GCP Project** with Compute Engine API enabled
   ```bash
   gcloud services enable compute.googleapis.com
   ```

## Quick Start

### 1. Clone and Configure

```bash
# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit with your project ID
nano terraform.tfvars
```

### 2. Deploy

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Deploy
terraform apply
```

### 3. Access Coolify

After deployment completes (~5-10 minutes for first installation):

```bash
# Get the Coolify URL
terraform output coolify_url

# SSH to check logs
gcloud compute ssh coolify-server --zone=us-central1-a --command="sudo tail -f /var/log/coolify-install.log"
```

Open the URL in your browser (port 8000) to complete Coolify setup.

## Configuration Options

| Variable | Description | Default |
|----------|-------------|---------|
| `project_id` | GCP Project ID | *required* |
| `region` | GCP Region | `us-central1` |
| `zone` | GCP Zone | `us-central1-a` |
| `machine_type` | Instance type | `e2-medium` |
| `disk_size` | Boot disk (GB) | `20` |
| `data_disk_size` | Data disk for /data (GB) | `50` |
| `instance_name` | Instance name | `coolify-server` |
| `gcs_bucket_name` | GCS bucket to mount (optional) | `""` |
| `gcs_mount_path` | Mount path for GCS bucket | `/mnt/gcs-storage` |
| `existing_ip_name` | Name of existing reserved IP | `""` |
| `existing_ip_address` | Use existing static IP | `""` (creates new) |

### Recommended Machine Types

| Type | vCPUs | RAM | Use Case |
|------|-------|-----|----------|
| `e2-small` | 2 | 2GB | Testing only |
| `e2-medium` | 2 | 4GB | Small projects |
| `e2-standard-2` | 2 | 8GB | Production |
| `e2-standard-4` | 4 | 16GB | Heavy workloads |

## GCS FUSE Storage (Optional)

Mount a GCS bucket for persistent storage across deployments:

```hcl
# terraform.tfvars
gcs_bucket_name = "your-bucket-name"
gcs_mount_path  = "/mnt/gcs-storage"  # optional, this is the default
```

The bucket will be mounted automatically on both first boot and quick boot paths.

## CI/CD with GitHub Actions

This repo includes a GitHub Actions workflow that auto-deploys on push to `main`.

### Setup

1. **Create GCS bucket for Terraform state**:
   ```bash
   gsutil mb -l us-central1 gs://YOUR_PROJECT-terraform-state
   gsutil versioning set on gs://YOUR_PROJECT-terraform-state
   ```

2. **Create service account with required permissions**:
   ```bash
   # Create service account
   gcloud iam service-accounts create terraform-ci --display-name="Terraform CI/CD"

   # Grant compute admin role
   gcloud projects add-iam-policy-binding YOUR_PROJECT \
     --member="serviceAccount:terraform-ci@YOUR_PROJECT.iam.gserviceaccount.com" \
     --role="roles/compute.admin" --condition=None

   # Grant storage admin role
   gcloud projects add-iam-policy-binding YOUR_PROJECT \
     --member="serviceAccount:terraform-ci@YOUR_PROJECT.iam.gserviceaccount.com" \
     --role="roles/storage.admin" --condition=None

   # Grant permission to use the default compute service account
   gcloud iam service-accounts add-iam-policy-binding \
     YOUR_PROJECT_NUMBER-compute@developer.gserviceaccount.com \
     --member="serviceAccount:terraform-ci@YOUR_PROJECT.iam.gserviceaccount.com" \
     --role="roles/iam.serviceAccountUser"

   # Create key file
   gcloud iam service-accounts keys create terraform-ci-key.json \
     --iam-account=terraform-ci@YOUR_PROJECT.iam.gserviceaccount.com
   ```

3. **Add GitHub Secrets** (Settings > Secrets > Actions):
   - `GCP_CREDENTIALS` - Contents of `terraform-ci-key.json`
   - `TF_VAR_PROJECT_ID` - Your GCP project ID
   - `TF_VAR_GCS_BUCKET_NAME` - GCS bucket for gcsfuse mount (optional, leave empty to skip)

4. **Update backend** in `main.tf`:
   ```hcl
   backend "gcs" {
     bucket = "YOUR_PROJECT-terraform-state"
     prefix = "coolify"
   }
   ```

### Workflow Behavior

- **Push to main**: Runs `terraform apply -auto-approve`
- **Pull requests**: Runs `terraform plan` only

## Idempotent Startup

The startup script has three boot paths:

- **Fresh Install**: No existing config (~5-10 minutes)
  - Formats and mounts data disk to `/data`
  - Installs Docker and Coolify
  - Creates SSH key for localhost server
  - Installs gcsfuse (if GCS bucket configured)

- **Quick Boot**: Config exists, postgres volume intact (~10 seconds)
  - Mounts data disk
  - Starts existing Coolify containers
  - **Preserves everything** - used for normal reboots

- **Recovery Boot**: Config exists, but postgres volume empty (~5-10 minutes)
  - Preserves existing `.env` (contains APP_KEY)
  - Runs fresh Coolify install
  - Restores original APP_KEY
  - Restores database from backup (if available in `/data/coolify/backups/`)
  - **Used after `terraform destroy` + `terraform apply`**

### Persistence Strategy

| Location | Persists across | Contains |
|----------|-----------------|----------|
| Boot disk | Reboots only | Coolify app, postgres Docker volume |
| Data disk `/data` | Destroy/apply cycles | Config, SSH keys, backups, user apps |

**Important**: Enable Coolify's built-in backups (Settings > Backup) for full recovery after `terraform destroy`.

## Security Notes

### Firewall

Open ports:
- 22 (SSH)
- 80 (HTTP)
- 443 (HTTPS)
- 8000 (Coolify UI)
- 6001-6002 (Coolify realtime services)

### Set Up a Domain

After installation:
1. Point your domain's A record to the external IP
2. Configure the domain in Coolify settings
3. Enable Let's Encrypt for automatic HTTPS

## Outputs

After deployment, Terraform provides:

```bash
terraform output external_ip    # Server IP address
terraform output coolify_url    # Admin panel URL (port 8000)
terraform output ssh_command    # SSH access command
```

## Troubleshooting

### Check Installation Status

```bash
# SSH into the instance
gcloud compute ssh coolify-server --zone=us-central1-a

# View installation log
sudo tail -f /var/log/coolify-install.log

# Check Coolify containers
sudo docker ps

# Check GCS mount
mountpoint /mnt/gcs-storage
```

### Common Issues

**Services not starting after reboot**: Check if quick boot path was taken:
```bash
sudo head -20 /var/log/coolify-install.log
```

**GCS mount failed**: Verify bucket exists and service account has access:
```bash
gsutil ls gs://YOUR_BUCKET
```

**Firewall blocking**: Verify firewall rules are applied:
```bash
gcloud compute firewall-rules list --filter="name~coolify"
```

**Realtime service not connecting**: Ensure ports 6001-6002 are open in firewall.

## Cleanup

Remove instance and firewall (disk and IP are preserved):

```bash
terraform destroy -target=google_compute_instance.coolify -target=google_compute_firewall.coolify
```

To fully destroy everything (requires removing `prevent_destroy` from main.tf):
```bash
terraform destroy
```

To manually delete preserved resources:
```bash
gcloud compute disks delete coolify-server-disk --zone=us-central1-a
gcloud compute addresses delete coolify-server-ip --region=us-central1
```

## Cost Estimate

Approximate monthly costs (us-central1):

| Component | Cost |
|-----------|------|
| e2-medium instance | ~$25/month |
| 20GB SSD boot disk | ~$3/month |
| 50GB SSD data disk | ~$8/month |
| Static IP (in use) | Free |
| GCS storage | ~$0.02/GB/month |
| Network egress | Variable |

**Total**: ~$36/month minimum

Use [Google Cloud Pricing Calculator](https://cloud.google.com/products/calculator) for precise estimates.

## License

MIT License - Feel free to use and modify.
