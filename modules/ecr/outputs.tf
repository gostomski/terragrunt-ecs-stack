output "registry_id" {
  value = aws_ecr_repository.repo.registry_id
}

output "repository_arn" {
  value = aws_ecr_repository.repo.arn
}

output "repository_url" {
  value = aws_ecr_repository.repo.repository_url
}

output "repository_name" {
  value = aws_ecr_repository.repo.name
}