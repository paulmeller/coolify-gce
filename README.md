# Easypanel on Google Compute Engine (Terraform)

Deploy [Easypanel](https://easypanel.io) - a modern server control panel - on Google Compute Engine using Terraform.

## Features

- **Automated Setup**: Docker and Easypanel installed via startup script
- **Idempotent Boots**: Fast restarts (~10s) with service preservation across `terraform destroy/apply`
- **Static IP**: Persistent external IP address
- **GCS Storage**: Mount Google Cloud Storage buckets via gcsfuse
- **Tailscale Integration**: Optional private networking with Tailscale
- **CI/CD Ready**: GitHub Actions workflow for auto-deploy on push
- **Daily Backups**: Automatic disk snapshots with 3-day retention
- **Ubuntu 24.04 LTS**: Latest long-term support release

## Prerequisites

1. **Google Cloud SDK** installed and authenticated
   ```bash
   gcloud auth login
   gcloud auth application-default login
   ```

2. **Terraform** >= 1.9 installed
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

### 3. Access Easypanel

After deployment completes (~3-5 minutes for first installation):

```bash
# Get the Easypanel URL
terraform output easypanel_url

# Check installation progress
terraform output installation_log_command | bash
```

Open the URL in your browser to complete Easypanel setup.

## Configuration Options

| Variable | Description | Default |
|----------|-------------|---------|
| `project_id` | GCP Project ID | *required* |
| `region` | GCP Region | `us-central1` |
| `zone` | GCP Zone | `us-central1-a` |
| `machine_type` | Instance type | `e2-medium` |
| `disk_size` | Boot disk (GB) | `50` |
| `instance_name` | Instance name | `easypanel-server` |
| `existing_ip_name` | Use existing static IP | `""` |
| `existing_ip_address` | Existing IP address | `""` |
| `gcs_bucket_name` | GCS bucket to mount | `""` |
| `gcs_mount_path` | Mount path for GCS bucket | `/mnt/easypanel-storage` |
| `tailscale_auth_key` | Tailscale auth key | `""` |
| `disable_public_admin` | Disable public port 3000 | `false` |
| `admin_ip_ranges` | IPs allowed to access admin | `["0.0.0.0/0"]` |

### Recommended Machine Types

| Type | vCPUs | RAM | Use Case |
|------|-------|-----|----------|
| `e2-small` | 2 | 2GB | Testing only |
| `e2-medium` | 2 | 4GB | Small projects |
| `e2-standard-2` | 2 | 8GB | Production |
| `e2-standard-4` | 4 | 16GB | Heavy workloads |

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

   > **Note**: Replace `YOUR_PROJECT_NUMBER` with your GCP project number (find it with `gcloud projects describe YOUR_PROJECT --format='value(projectNumber)'`)

3. **Add GitHub Secrets** (Settings → Secrets → Actions):
   - `GCP_CREDENTIALS` - Contents of `terraform-ci-key.json`
   - `TF_VAR_PROJECT_ID` - Your GCP project ID
   - `TF_VAR_EXISTING_IP_NAME` - Static IP name (if using)
   - `TF_VAR_EXISTING_IP_ADDRESS` - Static IP address (if using)
   - `TF_VAR_GCS_BUCKET_NAME` - GCS bucket for storage (if using)
   - `TF_VAR_TAILSCALE_AUTH_KEY` - Tailscale key (if using)

4. **Update backend** in `main.tf`:
   ```hcl
   backend "gcs" {
     bucket = "YOUR_PROJECT-terraform-state"
     prefix = "easypanel"
   }
   ```

### Workflow Behavior

- **Push to main**: Runs `terraform apply -auto-approve`
- **Pull requests**: Runs `terraform plan` only

## Idempotent Startup

The startup script detects existing installations and takes a fast path on subsequent boots:

- **First boot**: Full installation (~5-10 minutes)
- **Subsequent boots**: Quick boot (~10 seconds)
  - Starts Docker
  - Mounts GCS bucket (if configured)
  - Connects Tailscale (if configured)
  - **Preserves all running services**

This means `terraform destroy` + `terraform apply` preserves your Easypanel projects and running containers.

## Security Notes

### Restrict Admin Access

Use the `admin_ip_ranges` variable to restrict port 3000:

```hcl
admin_ip_ranges = ["YOUR_PUBLIC_IP/32"]
```

Or disable public admin access entirely with Tailscale:

```hcl
tailscale_auth_key    = "tskey-auth-..."
disable_public_admin  = true
```

### Set Up a Domain

After installation:
1. Point your domain's A record to the external IP
2. Configure the domain in Easypanel settings
3. Enable Let's Encrypt for automatic HTTPS

## Outputs

After deployment, Terraform provides:

```bash
terraform output external_ip          # Server IP address
terraform output easypanel_url        # Admin panel URL
terraform output ssh_command          # SSH access command
terraform output installation_log_command  # View install logs
terraform output gcs_mount_info       # GCS mount status
terraform output tailscale_info       # Tailscale status
```

## Troubleshooting

### Check Installation Status

```bash
# SSH into the instance
gcloud compute ssh easypanel-server --zone=us-central1-a

# View installation log
sudo tail -f /var/log/easypanel-install.log

# Check Docker services
sudo docker service ls

# List running containers
sudo docker ps
```

### Common Issues

**Port 3000 not accessible**: Wait 3-5 minutes for installation to complete

**Services not starting after reboot**: Check if quick boot path was taken:
```bash
sudo head -20 /var/log/easypanel-install.log
```

**GCS mount failed**: Verify bucket exists and service account has access:
```bash
gsutil ls gs://YOUR_BUCKET
```

**Firewall blocking**: Verify firewall rules are applied:
```bash
gcloud compute firewall-rules list --filter="name~easypanel"
```

## Cleanup

Remove all resources (disk is preserved by default):

```bash
terraform destroy
```

To also delete the disk:
```bash
gcloud compute disks delete easypanel-server-boot --zone=us-central1-a
```

## Cost Estimate

Approximate monthly costs (us-central1):

| Component | Cost |
|-----------|------|
| e2-medium instance | ~$25/month |
| 50GB SSD disk | ~$8/month |
| Static IP (in use) | Free |
| GCS storage | ~$0.02/GB/month |
| Network egress | Variable |

**Total**: ~$33/month minimum

Use [Google Cloud Pricing Calculator](https://cloud.google.com/products/calculator) for precise estimates.

## License

MIT License - Feel free to use and modify.
