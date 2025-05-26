# Example Variables for ECR Module

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-west-2"
}

# Repository Names
variable "frontend_repo_name" {
  description = "Name of the frontend ECR repository"
  type        = string
  default     = "frontend-app"
}

variable "backend_repo_name" {
  description = "Name of the backend ECR repository"
  type        = string
  default     = "backend-api"
}

variable "migrations_repo_name" {
  description = "Name of the migrations ECR repository"
  type        = string
  default     = "db-migrations"
}

variable "worker_repo_name" {
  description = "Name of the worker ECR repository"
  type        = string
  default     = "worker-jobs"
}

variable "shared_repo_name" {
  description = "Name of the shared ECR repository"
  type        = string
  default     = "shared-utilities"
}

# Configuration Options
variable "image_tag_mutability" {
  description = "The tag mutability setting for repositories (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "Image tag mutability must be either MUTABLE or IMMUTABLE."
  }
}

variable "encryption_type" {
  description = "The encryption type to use for repositories (AES256 or KMS)"
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "Encryption type must be either AES256 or KMS."
  }
}

variable "kms_key_id" {
  description = "The KMS key ID to use for encryption (only used when encryption_type is KMS)"
  type        = string
  default     = null
}

# Lifecycle Policy Configuration
variable "max_image_count" {
  description = "Maximum number of images to keep in repositories"
  type        = number
  default     = 10
}

variable "untagged_image_days" {
  description = "Number of days to keep untagged images"
  type        = number
  default     = 7
}

# Optional Features
variable "create_shared_repo" {
  description = "Whether to create a shared repository"
  type        = bool
  default     = false
}

variable "shared_repo_policy" {
  description = "JSON policy document for the shared repository (optional)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to all repositories"
  type        = map(string)
  default = {
    Environment = "example"
    Project     = "ecr-demo"
    ManagedBy   = "terraform"
  }
} 