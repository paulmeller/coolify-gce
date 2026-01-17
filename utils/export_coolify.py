#!/usr/bin/env python3
"""Export Coolify configuration to Terraform.

Usage:
    export COOLIFY_TOKEN="your-api-token"
    python export_coolify.py                    # Output JSON to stdout
    python export_coolify.py --json > data.json # Save JSON export
    python export_coolify.py --terraform        # Generate Terraform files
"""

import argparse
import json
import os
import re
import sys
from typing import Any
from urllib.request import Request, urlopen
from urllib.error import HTTPError, URLError

COOLIFY_URL = os.getenv("COOLIFY_URL", "http://35.184.84.184:8000")
COOLIFY_TOKEN = os.getenv("COOLIFY_TOKEN")


def fetch(endpoint: str) -> Any:
    """Fetch from Coolify API."""
    if not COOLIFY_TOKEN:
        raise ValueError("COOLIFY_TOKEN environment variable not set")

    url = f"{COOLIFY_URL}/api/v1/{endpoint}"
    headers = {
        "Authorization": f"Bearer {COOLIFY_TOKEN}",
        "Accept": "application/json",
    }
    req = Request(url, headers=headers)
    try:
        with urlopen(req, timeout=30) as resp:
            return json.loads(resp.read().decode())
    except HTTPError as e:
        print(f"HTTP Error fetching {endpoint}: {e.code} {e.reason}", file=sys.stderr)
        return None
    except URLError as e:
        print(f"URL Error fetching {endpoint}: {e.reason}", file=sys.stderr)
        return None


def export_all() -> dict:
    """Export all resources from Coolify."""
    resources = {}

    # Fetch each resource type
    endpoints = {
        "projects": "projects",
        "servers": "servers",
        "applications": "applications",
        "services": "services",
        "databases": "databases",
        "private_keys": "private-keys",
    }

    for name, endpoint in endpoints.items():
        print(f"Fetching {name}...", file=sys.stderr)
        data = fetch(endpoint)
        if data is not None:
            resources[name] = data
        else:
            resources[name] = []

    # Fetch environment variables for each service
    if resources.get("services"):
        for service in resources["services"]:
            uuid = service.get("uuid")
            if uuid:
                envs = fetch(f"services/{uuid}/envs")
                if envs:
                    service["environment_variables"] = envs

    return resources


def sanitize_name(name: str) -> str:
    """Convert name to valid Terraform resource name."""
    # Replace non-alphanumeric with underscore
    sanitized = re.sub(r'[^a-zA-Z0-9]', '_', name)
    # Remove leading digits
    sanitized = re.sub(r'^[0-9]+', '', sanitized)
    # Remove consecutive underscores
    sanitized = re.sub(r'_+', '_', sanitized)
    # Remove leading/trailing underscores
    sanitized = sanitized.strip('_')
    return sanitized.lower() or "unnamed"


def escape_hcl(value: Any) -> str:
    """Escape value for HCL."""
    if value is None:
        return '""'
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, (int, float)):
        return str(value)
    s = str(value)
    # Use heredoc for multiline strings
    if '\n' in s:
        return f'<<-EOT\n{s}\nEOT'
    return '"' + s.replace('\\', '\\\\').replace('"', '\\"') + '"'


def generate_provider_tf() -> str:
    """Generate main.tf with provider configuration."""
    return '''# Coolify Stack - Main Configuration
# Manages Coolify resources via SierraJC/coolify provider

terraform {
  required_version = ">= 1.0"
  required_providers {
    coolify = {
      source  = "SierraJC/coolify"
      version = "~> 0.10"
    }
  }
}

provider "coolify" {
  endpoint = var.coolify_endpoint
  token    = var.coolify_token
}
'''


def generate_backend_tf() -> str:
    """Generate backend.tf for GCS state."""
    return '''# Coolify Stack - Backend Configuration

terraform {
  backend "gcs" {
    bucket = "context-prompt-terraform-state"
    prefix = "coolify"
  }
}
'''


def generate_variables_tf() -> str:
    """Generate variables.tf."""
    return '''# Coolify Stack - Variables

variable "coolify_endpoint" {
  description = "Coolify API endpoint URL"
  type        = string
  default     = "http://35.184.84.184:8000"
}

variable "coolify_token" {
  description = "Coolify API token"
  type        = string
  sensitive   = true
}
'''


def generate_tfvars_example() -> str:
    """Generate terraform.tfvars.example."""
    return '''# Example Coolify Stack Variables
# Copy to terraform.tfvars and fill in values

coolify_endpoint = "http://35.184.84.184:8000"

# API token - set via environment variable instead:
# export TF_VAR_coolify_token="your-token"
'''


def generate_projects_tf(projects: list) -> str:
    """Generate Terraform for projects."""
    if not projects:
        return "# No projects found\n"

    output = "# Coolify Projects\n\n"
    for project in projects:
        name = project.get("name", "unnamed")
        uuid = project.get("uuid", "")
        description = project.get("description", "")

        resource_name = sanitize_name(name)

        output += f'''# Project: {name}
# UUID: {uuid}
# Import: terraform import coolify_project.{resource_name} {uuid}
resource "coolify_project" "{resource_name}" {{
  name        = {escape_hcl(name)}
  description = {escape_hcl(description or "")}
}}

'''
    return output


def generate_servers_tf(servers: list) -> str:
    """Generate Terraform for servers."""
    if not servers:
        return "# No servers found\n"

    output = "# Coolify Servers\n\n"
    for server in servers:
        name = server.get("name", "unnamed")
        uuid = server.get("uuid", "")
        description = server.get("description", "")
        ip = server.get("ip", "")
        user = server.get("user", "root")
        port = server.get("port", 22)
        private_key_id = server.get("private_key_id")

        resource_name = sanitize_name(name)

        output += f'''# Server: {name}
# UUID: {uuid}
# IP: {ip}
# Import: terraform import coolify_server.{resource_name} {uuid}
resource "coolify_server" "{resource_name}" {{
  name        = {escape_hcl(name)}
  description = {escape_hcl(description or "")}
  ip          = {escape_hcl(ip)}
  user        = {escape_hcl(user)}
  port        = {port}
'''
        if private_key_id:
            output += f'  private_key_uuid = {escape_hcl(str(private_key_id))}\n'

        output += "}\n\n"

    return output


def generate_services_tf(services: list, projects: list) -> str:
    """Generate Terraform for services."""
    if not services:
        return "# No services found\n"

    # Build project UUID to name mapping
    project_map = {p.get("uuid"): sanitize_name(p.get("name", "unnamed"))
                   for p in projects}

    output = "# Coolify Services\n\n"
    for service in services:
        name = service.get("name", "unnamed")
        uuid = service.get("uuid", "")
        description = service.get("description", "")
        service_type = service.get("type", "")
        project_uuid = service.get("project_uuid", "")
        environment_name = service.get("environment_name", "production")
        server_uuid = service.get("server_uuid", "")

        resource_name = sanitize_name(name)

        output += f'''# Service: {name}
# UUID: {uuid}
# Type: {service_type}
# Import: terraform import coolify_service.{resource_name} {uuid}
resource "coolify_service" "{resource_name}" {{
  name             = {escape_hcl(name)}
  description      = {escape_hcl(description or "")}
  project_uuid     = {escape_hcl(project_uuid)}
  server_uuid      = {escape_hcl(server_uuid)}
  environment_name = {escape_hcl(environment_name)}
  type             = {escape_hcl(service_type)}
'''

        # Add environment variables if present
        envs = service.get("environment_variables", [])
        if envs:
            for env in envs:
                key = env.get("key", "")
                value = env.get("value", "")
                is_build = env.get("is_build_time", False)
                output += f'''
  environment_variable {{
    key           = {escape_hcl(key)}
    value         = {escape_hcl(value)}
    is_build_time = {escape_hcl(is_build)}
  }}
'''

        output += "}\n\n"

    return output


def generate_private_keys_tf(private_keys: list) -> str:
    """Generate Terraform for private keys."""
    if not private_keys:
        return "# No private keys found\n"

    output = "# Coolify Private Keys\n"
    output += "# Note: Private key values should be stored securely and referenced via variables\n\n"

    for key in private_keys:
        name = key.get("name", "unnamed")
        uuid = key.get("uuid", "")
        description = key.get("description", "")

        resource_name = sanitize_name(name)

        output += f'''# Private Key: {name}
# UUID: {uuid}
# Import: terraform import coolify_private_key.{resource_name} {uuid}
# Note: The actual private key value must be provided via variable
resource "coolify_private_key" "{resource_name}" {{
  name        = {escape_hcl(name)}
  description = {escape_hcl(description or "")}
  private_key = var.private_key_{resource_name}  # Sensitive - use variable
}}

variable "private_key_{resource_name}" {{
  description = "Private key for {name}"
  type        = string
  sensitive   = true
  default     = ""  # Provide via TF_VAR or terraform.tfvars
}}

'''

    return output


def generate_applications_tf(applications: list) -> str:
    """Generate Terraform for applications (partial support)."""
    if not applications:
        return "# No applications found\n"

    output = "# Coolify Applications\n"
    output += "# Note: Application support is partial in the provider\n\n"

    for app in applications:
        name = app.get("name", "unnamed")
        uuid = app.get("uuid", "")
        fqdn = app.get("fqdn", "")
        git_repository = app.get("git_repository", "")
        git_branch = app.get("git_branch", "")

        resource_name = sanitize_name(name)

        output += f'''# Application: {name}
# UUID: {uuid}
# FQDN: {fqdn}
# Git: {git_repository} ({git_branch})
# Note: Review provider docs for supported attributes
# Import: terraform import coolify_application.{resource_name} {uuid}
#
# resource "coolify_application" "{resource_name}" {{
#   name           = {escape_hcl(name)}
#   project_uuid   = "<project-uuid>"
#   server_uuid    = "<server-uuid>"
#   git_repository = {escape_hcl(git_repository)}
#   git_branch     = {escape_hcl(git_branch)}
# }}

'''

    return output


def generate_databases_tf(databases: list) -> str:
    """Generate Terraform for databases (partial support)."""
    if not databases:
        return "# No databases found\n"

    output = "# Coolify Databases\n"
    output += "# Note: Database support is partial in the provider\n\n"

    for db in databases:
        name = db.get("name", "unnamed")
        uuid = db.get("uuid", "")
        db_type = db.get("type", "")

        resource_name = sanitize_name(name)

        output += f'''# Database: {name}
# UUID: {uuid}
# Type: {db_type}
# Note: Review provider docs for supported attributes
# Import: terraform import coolify_database.{resource_name} {uuid}
#
# resource "coolify_database" "{resource_name}" {{
#   name         = {escape_hcl(name)}
#   project_uuid = "<project-uuid>"
#   server_uuid  = "<server-uuid>"
#   type         = {escape_hcl(db_type)}
# }}

'''

    return output


def generate_import_script(data: dict) -> str:
    """Generate a shell script to import existing resources."""
    output = '''#!/bin/bash
# Import script for existing Coolify resources
# Run from stacks/coolify directory after terraform init

set -e

'''

    # Projects
    for project in data.get("projects", []):
        name = sanitize_name(project.get("name", "unnamed"))
        uuid = project.get("uuid", "")
        output += f'echo "Importing project: {name}"\n'
        output += f'terraform import coolify_project.{name} {uuid}\n\n'

    # Servers
    for server in data.get("servers", []):
        name = sanitize_name(server.get("name", "unnamed"))
        uuid = server.get("uuid", "")
        output += f'echo "Importing server: {name}"\n'
        output += f'terraform import coolify_server.{name} {uuid}\n\n'

    # Services
    for service in data.get("services", []):
        name = sanitize_name(service.get("name", "unnamed"))
        uuid = service.get("uuid", "")
        output += f'echo "Importing service: {name}"\n'
        output += f'terraform import coolify_service.{name} {uuid}\n\n'

    # Private Keys
    for key in data.get("private_keys", []):
        name = sanitize_name(key.get("name", "unnamed"))
        uuid = key.get("uuid", "")
        output += f'echo "Importing private key: {name}"\n'
        output += f'terraform import coolify_private_key.{name} {uuid}\n\n'

    output += 'echo "Import complete!"\n'
    return output


def write_terraform_files(data: dict, output_dir: str = "../stacks/coolify"):
    """Write all Terraform files to the output directory."""
    import os

    os.makedirs(output_dir, exist_ok=True)

    files = {
        "main.tf": generate_provider_tf(),
        "backend.tf": generate_backend_tf(),
        "variables.tf": generate_variables_tf(),
        "terraform.tfvars.example": generate_tfvars_example(),
        "projects.tf": generate_projects_tf(data.get("projects", [])),
        "servers.tf": generate_servers_tf(data.get("servers", [])),
        "services.tf": generate_services_tf(
            data.get("services", []),
            data.get("projects", [])
        ),
        "private_keys.tf": generate_private_keys_tf(data.get("private_keys", [])),
        "applications.tf": generate_applications_tf(data.get("applications", [])),
        "databases.tf": generate_databases_tf(data.get("databases", [])),
    }

    for filename, content in files.items():
        filepath = os.path.join(output_dir, filename)
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Written: {filepath}", file=sys.stderr)

    # Write import script
    import_script = os.path.join(output_dir, "import.sh")
    with open(import_script, 'w') as f:
        f.write(generate_import_script(data))
    os.chmod(import_script, 0o755)
    print(f"Written: {import_script}", file=sys.stderr)


def main():
    parser = argparse.ArgumentParser(
        description="Export Coolify configuration to Terraform"
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Output raw JSON export to stdout"
    )
    parser.add_argument(
        "--terraform",
        action="store_true",
        help="Generate Terraform files in stacks/coolify/"
    )
    parser.add_argument(
        "--output-dir",
        default="../stacks/coolify",
        help="Output directory for Terraform files (default: ../stacks/coolify)"
    )
    args = parser.parse_args()

    if not COOLIFY_TOKEN:
        print("Error: COOLIFY_TOKEN environment variable not set", file=sys.stderr)
        print("Generate a token at: Coolify UI → Keys & Tokens → API Tokens", file=sys.stderr)
        sys.exit(1)

    # Export all data
    data = export_all()

    if args.json:
        print(json.dumps(data, indent=2))
    elif args.terraform:
        write_terraform_files(data, args.output_dir)
        print("\nTerraform files generated!", file=sys.stderr)
        print(f"Next steps:", file=sys.stderr)
        print(f"  1. cd {args.output_dir}", file=sys.stderr)
        print(f"  2. terraform init", file=sys.stderr)
        print(f"  3. ./import.sh  # Import existing resources", file=sys.stderr)
        print(f"  4. terraform plan  # Should show no changes", file=sys.stderr)
    else:
        # Default: print JSON summary
        print(json.dumps(data, indent=2))


if __name__ == "__main__":
    main()
