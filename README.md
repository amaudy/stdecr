# ECR Repository Terraform Module

This Terraform module creates an Amazon ECR (Elastic Container Registry) repository with proper configuration including lifecycle policies, image scanning, and encryption.

## Features

- **ECR Repository**: Secure container image registry
- **Image Scanning**: Automatic vulnerability scanning on push
- **Lifecycle Policies**: Automatic cleanup of old images
- **Encryption**: AES256 or KMS encryption support
- **Repository Policies**: Optional custom access policies
- **Docker Commands**: Helpful output commands for Docker operations

## Required Inputs

- `name`: Name of the ECR repository
- `region`: AWS region where the ECR repository will be created

## Primary Outputs

- `arn`: ARN of the ECR repository
- `name`: Name of the ECR repository

## Usage Examples

### Basic ECR Repository

```hcl
module "my_app_ecr" {
  source = "./stdecr"

  # Required inputs
  name   = "my-application"
  region = "us-west-2"

  tags = {
    Environment = "production"
    Application = "my-app"
  }
}

# Get the repository ARN and name
output "ecr_arn" {
  value = module.my_app_ecr.arn
}

output "ecr_name" {
  value = module.my_app_ecr.name
}

output "ecr_url" {
  value = module.my_app_ecr.repository_url
}
```

### ECR Repository with Custom Configuration

```hcl
module "secure_app_ecr" {
  source = "./stdecr"

  # Required inputs
  name   = "secure-application"
  region = "us-east-1"

  # Security configuration
  image_tag_mutability = "IMMUTABLE"
  scan_on_push         = true
  encryption_type      = "KMS"
  kms_key_id          = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"

  # Lifecycle policy
  enable_lifecycle_policy = true
  max_image_count        = 20
  untagged_image_days    = 3

  tags = {
    Environment = "production"
    Application = "secure-app"
    Compliance  = "required"
  }
}
```

### ECR Repository with Custom Repository Policy

```hcl
# Custom repository policy for cross-account access
data "aws_iam_policy_document" "ecr_policy" {
  statement {
    sid    = "CrossAccountAccess"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::123456789012:root"]
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability"
    ]
  }
}

module "shared_ecr" {
  source = "./stdecr"

  # Required inputs
  name   = "shared-application"
  region = "us-west-2"

  # Custom repository policy
  repository_policy = data.aws_iam_policy_document.ecr_policy.json

  tags = {
    Environment = "shared"
    Purpose     = "cross-account"
  }
}
```

### Multiple ECR Repositories

```hcl
# Frontend application
module "frontend_ecr" {
  source = "./stdecr"

  name   = "frontend-app"
  region = var.aws_region

  lifecycle_tag_prefixes = ["v", "release"]
  max_image_count       = 15

  tags = {
    Component = "frontend"
    Team      = "ui-team"
  }
}

# Backend API
module "backend_ecr" {
  source = "./stdecr"

  name   = "backend-api"
  region = var.aws_region

  image_tag_mutability = "IMMUTABLE"
  max_image_count     = 25

  tags = {
    Component = "backend"
    Team      = "api-team"
  }
}

# Database migrations
module "migrations_ecr" {
  source = "./stdecr"

  name   = "db-migrations"
  region = var.aws_region

  enable_lifecycle_policy = false  # Keep all migration images

  tags = {
    Component = "database"
    Team      = "data-team"
  }
}
```

## Input Variables

### Required Variables

| Name | Description | Type |
|------|-------------|------|
| `name` | Name of the ECR repository | `string` |
| `region` | AWS region where the repository will be created | `string` |

### Optional Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `image_tag_mutability` | Tag mutability setting (MUTABLE or IMMUTABLE) | `string` | `"MUTABLE"` |
| `scan_on_push` | Enable image scanning on push | `bool` | `true` |
| `encryption_type` | Encryption type (AES256 or KMS) | `string` | `"AES256"` |
| `kms_key_id` | KMS key ID for encryption | `string` | `null` |
| `repository_policy` | JSON policy document for the repository | `string` | `null` |
| `enable_lifecycle_policy` | Enable lifecycle policy | `bool` | `true` |
| `max_image_count` | Maximum number of images to keep | `number` | `10` |
| `untagged_image_days` | Days to keep untagged images | `number` | `7` |
| `lifecycle_tag_prefixes` | Tag prefixes for lifecycle policy | `list(string)` | `["v", "release", "latest"]` |
| `tags` | Tags to assign to the repository | `map(string)` | `{}` |

## Outputs

### Primary Outputs

| Name | Description |
|------|-------------|
| `arn` | **ARN of the ECR repository** |
| `name` | **Name of the ECR repository** |

### Additional Outputs

| Name | Description |
|------|-------------|
| `repository_url` | URL of the ECR repository |
| `registry_id` | Registry ID where the repository was created |
| `docker_login_command` | AWS CLI command to authenticate Docker |
| `docker_build_command` | Example Docker build command |
| `docker_tag_command` | Example Docker tag command |
| `docker_push_command` | Example Docker push command |

## Docker Workflow

After creating the ECR repository, use these commands to push images:

```bash
# 1. Get the Docker login command from Terraform output
terraform output docker_login_command

# 2. Authenticate Docker with ECR
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-west-2.amazonaws.com

# 3. Build your Docker image
docker build -t my-application .

# 4. Tag the image for ECR
docker tag my-application:latest 123456789012.dkr.ecr.us-west-2.amazonaws.com/my-application:latest

# 5. Push the image to ECR
docker push 123456789012.dkr.ecr.us-west-2.amazonaws.com/my-application:latest
```

## Integration with ECS Service Module

This ECR module works perfectly with the `stdecsservice` module:

```hcl
# Create ECR repository
module "app_ecr" {
  source = "./stdecr"

  name   = "my-web-app"
  region = "us-west-2"
}

# Deploy to ECS using the ECR image
module "app_service" {
  source = "./stdecsservice"

  # Use the ECR repository URL as the Docker image
  docker_image   = "${module.app_ecr.repository_url}:latest"
  container_port = 8000

  service_name    = "my-web-app"
  cluster_id      = var.ecs_cluster_id
  vpc_id          = var.vpc_id
  private_subnets = var.private_subnets

  depends_on = [module.app_ecr]
}
```

## Security Best Practices

1. **Image Scanning**: Always enable `scan_on_push = true` for security
2. **Immutable Tags**: Use `image_tag_mutability = "IMMUTABLE"` for production
3. **Encryption**: Consider using KMS encryption for sensitive applications
4. **Lifecycle Policies**: Enable automatic cleanup to manage costs
5. **Repository Policies**: Implement least privilege access controls

## Cost Optimization

- **Lifecycle Policies**: Automatically delete old images to reduce storage costs
- **Image Compression**: Use multi-stage Docker builds and Alpine base images
- **Tag Management**: Use semantic versioning and avoid excessive tags
- **Regional Placement**: Create repositories in the same region as your compute resources

## Troubleshooting

1. **Authentication Issues**: Ensure AWS CLI is configured and ECR permissions are granted
2. **Push Failures**: Check repository policies and network connectivity
3. **Image Scanning**: Verify that image scanning is enabled and check scan results
4. **Lifecycle Policy**: Monitor image deletion and adjust policies as needed

## Prerequisites

1. **AWS CLI**: Configured with appropriate permissions
2. **Docker**: Installed and running
3. **ECR Permissions**: IAM permissions for ECR operations

## License

This module is provided as-is for educational and production use. 