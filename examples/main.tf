# Example: Create ECR repositories for a multi-tier application
# This example demonstrates how to create ECR repositories for different components

# Configure the AWS Provider
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure AWS Provider
provider "aws" {
  region = var.aws_region
}

# Frontend Application ECR Repository
module "frontend_ecr" {
  source = "../"

  # Required inputs
  name   = var.frontend_repo_name
  region = var.aws_region

  # Frontend-specific configuration
  image_tag_mutability    = var.image_tag_mutability
  scan_on_push            = true
  enable_lifecycle_policy = true
  max_image_count         = var.max_image_count
  untagged_image_days     = var.untagged_image_days

  # Frontend typically uses semantic versioning
  lifecycle_tag_prefixes = ["v", "release", "latest", "staging"]

  tags = merge(var.tags, {
    Component = "frontend"
    Team      = "ui-team"
  })
}

# Backend API ECR Repository
module "backend_ecr" {
  source = "../"

  # Required inputs
  name   = var.backend_repo_name
  region = var.aws_region

  # Backend-specific configuration (more secure)
  image_tag_mutability    = "IMMUTABLE" # Immutable for production APIs
  scan_on_push            = true
  encryption_type         = var.encryption_type
  kms_key_id              = var.kms_key_id
  enable_lifecycle_policy = true
  max_image_count         = var.max_image_count
  untagged_image_days     = 3 # Shorter retention for backend

  lifecycle_tag_prefixes = ["v", "release", "hotfix"]

  tags = merge(var.tags, {
    Component = "backend"
    Team      = "api-team"
  })
}

# Database Migration ECR Repository
module "migrations_ecr" {
  source = "../"

  # Required inputs
  name   = var.migrations_repo_name
  region = var.aws_region

  # Migration-specific configuration
  image_tag_mutability    = "IMMUTABLE" # Never overwrite migration images
  scan_on_push            = true
  enable_lifecycle_policy = false # Keep all migration images for rollback

  tags = merge(var.tags, {
    Component = "database"
    Team      = "data-team"
    Purpose   = "migrations"
  })
}

# Worker/Job Processing ECR Repository
module "worker_ecr" {
  source = "../"

  # Required inputs
  name   = var.worker_repo_name
  region = var.aws_region

  # Worker-specific configuration
  image_tag_mutability    = var.image_tag_mutability
  scan_on_push            = true
  enable_lifecycle_policy = true
  max_image_count         = 15 # Keep more versions for workers
  untagged_image_days     = var.untagged_image_days

  lifecycle_tag_prefixes = ["v", "release", "worker"]

  tags = merge(var.tags, {
    Component = "worker"
    Team      = "backend-team"
  })
}

# Optional: Shared/Common ECR Repository
module "shared_ecr" {
  count = var.create_shared_repo ? 1 : 0

  source = "../"

  # Required inputs
  name   = var.shared_repo_name
  region = var.aws_region

  # Shared repository configuration
  image_tag_mutability    = "MUTABLE"
  scan_on_push            = true
  enable_lifecycle_policy = true
  max_image_count         = 20
  untagged_image_days     = var.untagged_image_days

  # Custom repository policy for cross-team access
  repository_policy = var.shared_repo_policy

  tags = merge(var.tags, {
    Component = "shared"
    Team      = "platform-team"
    Purpose   = "shared-utilities"
  })
} 