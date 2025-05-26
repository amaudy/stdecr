# ECR Module Example

This directory contains a complete example of how to use the ECR module to create multiple ECR repositories for a multi-tier application.

## What This Example Does

1. **Creates Frontend ECR Repository** for web application images
2. **Creates Backend ECR Repository** with enhanced security (immutable tags)
3. **Creates Migrations ECR Repository** with no lifecycle policy (keep all versions)
4. **Creates Worker ECR Repository** for background job processing
5. **Optionally creates Shared ECR Repository** for common utilities

## Prerequisites

Before running this example, ensure you have:

1. **AWS CLI configured** with appropriate permissions
2. **Terraform installed** (version >= 1.0)
3. **ECR permissions** for creating and managing repositories
4. **Docker installed** (for pushing images to the repositories)

## Quick Start

### 1. Configure Variables

Copy the example variables file and customize it:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your specific values:

```hcl
# AWS Configuration
aws_region = "us-west-2"

# Repository Names
frontend_repo_name   = "my-app-frontend"
backend_repo_name    = "my-app-backend"
migrations_repo_name = "my-app-migrations"
worker_repo_name     = "my-app-worker"

# Security Configuration
image_tag_mutability = "MUTABLE"    # or "IMMUTABLE" for production
encryption_type      = "AES256"     # or "KMS" for enhanced security
```

### 2. Deploy the Repositories

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

### 3. Use the Repositories

After deployment, Terraform will output the repository URLs and ARNs:

```
Outputs:

all_repository_urls = {
  "backend" = "123456789012.dkr.ecr.us-west-2.amazonaws.com/my-app-backend"
  "frontend" = "123456789012.dkr.ecr.us-west-2.amazonaws.com/my-app-frontend"
  "migrations" = "123456789012.dkr.ecr.us-west-2.amazonaws.com/my-app-migrations"
  "worker" = "123456789012.dkr.ecr.us-west-2.amazonaws.com/my-app-worker"
}
```

## Repository Configurations

### Frontend Repository
- **Tag Mutability**: Configurable (default: MUTABLE)
- **Image Scanning**: Enabled
- **Lifecycle Policy**: Enabled (keeps last 15 images)
- **Tag Prefixes**: `["v", "release", "latest", "staging"]`

### Backend Repository
- **Tag Mutability**: IMMUTABLE (for production security)
- **Image Scanning**: Enabled
- **Encryption**: Configurable (supports KMS)
- **Lifecycle Policy**: Enabled (shorter retention for untagged images)
- **Tag Prefixes**: `["v", "release", "hotfix"]`

### Migrations Repository
- **Tag Mutability**: IMMUTABLE (never overwrite migration images)
- **Image Scanning**: Enabled
- **Lifecycle Policy**: DISABLED (keep all migration images for rollback)

### Worker Repository
- **Tag Mutability**: Configurable
- **Image Scanning**: Enabled
- **Lifecycle Policy**: Enabled (keeps more versions for workers)
- **Tag Prefixes**: `["v", "release", "worker"]`

### Shared Repository (Optional)
- **Tag Mutability**: MUTABLE
- **Image Scanning**: Enabled
- **Custom Policy**: Supports cross-account access
- **Lifecycle Policy**: Enabled

## Docker Workflow

### 1. Authenticate with ECR

```bash
# Get the login command from Terraform output
terraform output docker_login_command

# Or use AWS CLI directly
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-west-2.amazonaws.com
```

### 2. Build and Push Images

```bash
# Frontend
docker build -t my-app-frontend ./frontend
docker tag my-app-frontend:latest 123456789012.dkr.ecr.us-west-2.amazonaws.com/my-app-frontend:latest
docker push 123456789012.dkr.ecr.us-west-2.amazonaws.com/my-app-frontend:latest

# Backend
docker build -t my-app-backend ./backend
docker tag my-app-backend:v1.0.0 123456789012.dkr.ecr.us-west-2.amazonaws.com/my-app-backend:v1.0.0
docker push 123456789012.dkr.ecr.us-west-2.amazonaws.com/my-app-backend:v1.0.0

# Migrations
docker build -t my-app-migrations ./migrations
docker tag my-app-migrations:migration-001 123456789012.dkr.ecr.us-west-2.amazonaws.com/my-app-migrations:migration-001
docker push 123456789012.dkr.ecr.us-west-2.amazonaws.com/my-app-migrations:migration-001

# Worker
docker build -t my-app-worker ./worker
docker tag my-app-worker:latest 123456789012.dkr.ecr.us-west-2.amazonaws.com/my-app-worker:latest
docker push 123456789012.dkr.ecr.us-west-2.amazonaws.com/my-app-worker:latest
```

## Integration with ECS

Use these ECR repositories with the ECS service module:

```hcl
# Deploy frontend service
module "frontend_service" {
  source = "../../stdecsservice"

  docker_image   = "${module.frontend_ecr.repository_url}:latest"
  container_port = 3000
  service_name   = "frontend-service"
  # ... other ECS configuration
}

# Deploy backend service
module "backend_service" {
  source = "../../stdecsservice"

  docker_image   = "${module.backend_ecr.repository_url}:v1.0.0"
  container_port = 8000
  service_name   = "backend-service"
  # ... other ECS configuration
}
```

## Environment-Specific Configurations

### Development Environment
```hcl
image_tag_mutability = "MUTABLE"
encryption_type      = "AES256"
max_image_count      = 10
untagged_image_days  = 14
```

### Staging Environment
```hcl
image_tag_mutability = "MUTABLE"
encryption_type      = "AES256"
max_image_count      = 15
untagged_image_days  = 7
```

### Production Environment
```hcl
image_tag_mutability = "IMMUTABLE"
encryption_type      = "KMS"
max_image_count      = 25
untagged_image_days  = 3
```

## Monitoring and Management

### View Repository Information
```bash
# List all repositories
aws ecr describe-repositories --region us-west-2

# Get repository details
aws ecr describe-repositories --repository-names my-app-frontend --region us-west-2

# List images in a repository
aws ecr list-images --repository-name my-app-frontend --region us-west-2
```

### Image Scanning Results
```bash
# Get scan results
aws ecr describe-image-scan-findings --repository-name my-app-frontend --image-id imageTag=latest --region us-west-2
```

## Cleanup

To destroy all repositories and their contents:

```bash
terraform destroy
```

**Warning**: This will delete all repositories and their images. Make sure you have backups if needed.

## Cost Considerations

- **Storage**: Pay for image storage (first 500MB free per month)
- **Data Transfer**: Pay for image pulls outside AWS
- **Lifecycle Policies**: Help reduce storage costs by automatically cleaning up old images

## Security Best Practices

1. **Enable Image Scanning**: Always scan images for vulnerabilities
2. **Use Immutable Tags**: For production environments
3. **Implement Lifecycle Policies**: To manage storage costs and security
4. **Use KMS Encryption**: For sensitive applications
5. **Repository Policies**: Implement least privilege access

## Troubleshooting

1. **Authentication Issues**: Ensure AWS CLI is configured and ECR permissions are granted
2. **Push Failures**: Check repository policies and network connectivity
3. **Image Scanning**: Verify scanning is enabled and check results
4. **Lifecycle Policy**: Monitor image deletion and adjust policies as needed

## Next Steps

- Set up CI/CD pipelines to automatically build and push images
- Implement image vulnerability scanning in your pipeline
- Configure monitoring and alerting for repository events
- Set up cross-region replication for disaster recovery