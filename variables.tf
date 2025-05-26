# Required Variables
variable "name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "region" {
  description = "AWS region where the ECR repository will be created"
  type        = string
}

# Optional Variables with Defaults
variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "Image tag mutability must be either MUTABLE or IMMUTABLE."
  }
}

variable "scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "The encryption type to use for the repository (AES256 or KMS)"
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

variable "repository_policy" {
  description = "JSON policy document for the ECR repository (optional)"
  type        = string
  default     = null
}

variable "enable_lifecycle_policy" {
  description = "Whether to enable lifecycle policy for the repository"
  type        = bool
  default     = true
}

variable "max_image_count" {
  description = "Maximum number of images to keep in the repository"
  type        = number
  default     = 10
}

variable "untagged_image_days" {
  description = "Number of days to keep untagged images"
  type        = number
  default     = 7
}

variable "lifecycle_tag_prefixes" {
  description = "List of tag prefixes to apply lifecycle policy to"
  type        = list(string)
  default     = ["v", "release", "latest"]
}

variable "tags" {
  description = "A map of tags to assign to the ECR repository"
  type        = map(string)
  default     = {}
}

# VPC Endpoints Configuration (for private ECR access)
variable "create_vpc_endpoints" {
  description = "Whether to create VPC endpoints for private ECR access"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "VPC ID where VPC endpoints will be created (required if create_vpc_endpoints is true)"
  type        = string
  default     = ""
}

variable "vpc_cidr_block" {
  description = "CIDR block of the VPC (required if create_vpc_endpoints is true)"
  type        = string
  default     = ""
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for VPC endpoints (required if create_vpc_endpoints is true)"
  type        = list(string)
  default     = []
}

variable "route_table_ids" {
  description = "List of route table IDs for S3 gateway endpoint (required if create_vpc_endpoints is true)"
  type        = list(string)
  default     = []
}

variable "create_logs_endpoint" {
  description = "Whether to create CloudWatch Logs VPC endpoint (useful for ECS logging)"
  type        = bool
  default     = true
} 