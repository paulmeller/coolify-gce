# Easypanel on Google Compute Engine (Terraform)

Deploy [Easypanel](https://easypanel.io) - a modern server control panel - on Google Compute Engine using Terraform.

## Features

- **Automated Setup**: Docker and Easypanel installed via startup script
- **Static IP**: Persistent external IP address
- **Firewall Rules**: Ports 80, 443, and 3000 configured
- **SSD Storage**: Fast boot disk with configurable size
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

### 3. Access Easypanel

After deployment completes (~3-5 minutes for installation):

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

### Recommended Machine Types

| Type | vCPUs | RAM | Use Case |
|------|-------|-----|----------|
| `e2-small` | 2 | 2GB | Testing only |
| `e2-medium` | 2 | 4GB | Small projects |
| `e2-standard-2` | 2 | 8GB | Production |
| `e2-standard-4` | 4 | 16GB | Heavy workloads |

## Security Notes

### Restrict Admin Access

Edit `main.tf` to restrict port 3000 to your IP:

```hcl
resource "google_compute_firewall" "easypanel_admin" {
  # ...
  source_ranges = ["YOUR_PUBLIC_IP/32"]
}
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
```

## Troubleshooting

### Check Installation Status

```bash
# SSH into the instance
gcloud compute ssh easypanel-server --zone=us-central1-a

# View installation log
sudo tail -f /var/log/easypanel-install.log

# Check Docker status
sudo systemctl status docker

# List running containers
sudo docker ps
```

### Common Issues

**Port 3000 not accessible**: Wait 3-5 minutes for installation to complete

**Docker not starting**: Check cloud-init logs:
```bash
sudo cat /var/log/cloud-init-output.log
```

**Firewall blocking**: Verify firewall rules are applied:
```bash
gcloud compute firewall-rules list --filter="name~easypanel"
```

## Cleanup

Remove all resources:

```bash
terraform destroy
```

## Cost Estimate

Approximate monthly costs (us-central1):

| Component | Cost |
|-----------|------|
| e2-medium instance | ~$25/month |
| 50GB SSD disk | ~$8/month |
| Static IP (in use) | Free |
| Network egress | Variable |

**Total**: ~$33/month minimum

Use [Google Cloud Pricing Calculator](https://cloud.google.com/products/calculator) for precise estimates.

## License

MIT License - Feel free to use and modify.
