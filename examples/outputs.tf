# Example Outputs

# Frontend Repository Outputs
output "frontend_ecr_arn" {
  description = "ARN of the frontend ECR repository"
  value       = module.frontend_ecr.arn
}

output "frontend_ecr_name" {
  description = "Name of the frontend ECR repository"
  value       = module.frontend_ecr.name
}

output "frontend_ecr_url" {
  description = "URL of the frontend ECR repository"
  value       = module.frontend_ecr.repository_url
}

# Backend Repository Outputs
output "backend_ecr_arn" {
  description = "ARN of the backend ECR repository"
  value       = module.backend_ecr.arn
}

output "backend_ecr_name" {
  description = "Name of the backend ECR repository"
  value       = module.backend_ecr.name
}

output "backend_ecr_url" {
  description = "URL of the backend ECR repository"
  value       = module.backend_ecr.repository_url
}

# Migrations Repository Outputs
output "migrations_ecr_arn" {
  description = "ARN of the migrations ECR repository"
  value       = module.migrations_ecr.arn
}

output "migrations_ecr_name" {
  description = "Name of the migrations ECR repository"
  value       = module.migrations_ecr.name
}

output "migrations_ecr_url" {
  description = "URL of the migrations ECR repository"
  value       = module.migrations_ecr.repository_url
}

# Worker Repository Outputs
output "worker_ecr_arn" {
  description = "ARN of the worker ECR repository"
  value       = module.worker_ecr.arn
}

output "worker_ecr_name" {
  description = "Name of the worker ECR repository"
  value       = module.worker_ecr.name
}

output "worker_ecr_url" {
  description = "URL of the worker ECR repository"
  value       = module.worker_ecr.repository_url
}

# Shared Repository Outputs (conditional)
output "shared_ecr_arn" {
  description = "ARN of the shared ECR repository"
  value       = var.create_shared_repo ? module.shared_ecr[0].arn : null
}

output "shared_ecr_name" {
  description = "Name of the shared ECR repository"
  value       = var.create_shared_repo ? module.shared_ecr[0].name : null
}

output "shared_ecr_url" {
  description = "URL of the shared ECR repository"
  value       = var.create_shared_repo ? module.shared_ecr[0].repository_url : null
}

# Docker Commands for All Repositories
output "docker_login_command" {
  description = "Docker login command for ECR"
  value       = module.frontend_ecr.docker_login_command
}

# Summary of All Repository URLs
output "all_repository_urls" {
  description = "Map of all ECR repository URLs"
  value = {
    frontend   = module.frontend_ecr.repository_url
    backend    = module.backend_ecr.repository_url
    migrations = module.migrations_ecr.repository_url
    worker     = module.worker_ecr.repository_url
    shared     = var.create_shared_repo ? module.shared_ecr[0].repository_url : null
  }
}

# Summary of All Repository ARNs
output "all_repository_arns" {
  description = "Map of all ECR repository ARNs"
  value = {
    frontend   = module.frontend_ecr.arn
    backend    = module.backend_ecr.arn
    migrations = module.migrations_ecr.arn
    worker     = module.worker_ecr.arn
    shared     = var.create_shared_repo ? module.shared_ecr[0].arn : null
  }
} 