# Primary Outputs (as requested)
output "arn" {
  description = "ARN of the ECR repository"
  value       = aws_ecr_repository.main.arn
}

output "name" {
  description = "Name of the ECR repository"
  value       = aws_ecr_repository.main.name
}

# Additional Useful Outputs
output "repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.main.repository_url
}

output "registry_id" {
  description = "Registry ID where the repository was created"
  value       = aws_ecr_repository.main.registry_id
}

output "repository_uri" {
  description = "URI of the ECR repository (same as repository_url)"
  value       = aws_ecr_repository.main.repository_url
}

output "image_tag_mutability" {
  description = "Image tag mutability setting for the repository"
  value       = aws_ecr_repository.main.image_tag_mutability
}

output "encryption_configuration" {
  description = "Encryption configuration for the repository"
  value       = aws_ecr_repository.main.encryption_configuration
}

output "image_scanning_configuration" {
  description = "Image scanning configuration for the repository"
  value       = aws_ecr_repository.main.image_scanning_configuration
}

# Docker Commands for Reference
output "docker_login_command" {
  description = "AWS CLI command to authenticate Docker with ECR"
  value       = "aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${aws_ecr_repository.main.repository_url}"
}

output "docker_build_command" {
  description = "Example Docker build command"
  value       = "docker build -t ${aws_ecr_repository.main.name} ."
}

output "docker_tag_command" {
  description = "Example Docker tag command"
  value       = "docker tag ${aws_ecr_repository.main.name}:latest ${aws_ecr_repository.main.repository_url}:latest"
}

output "docker_push_command" {
  description = "Example Docker push command"
  value       = "docker push ${aws_ecr_repository.main.repository_url}:latest"
} 