resource "aws_ecr_repository" "repo" {
  name                          = var.repo_name
  tags                          = merge(var.tags, {service_name=var.ecs_service_name})
  image_tag_mutability          = var.image_tag_mutability
  image_scanning_configuration {
    scan_on_push                = var.scan_image_on_push
  }
}

resource "aws_ecr_lifecycle_policy" "lifecycle-policy" {
  repository                    = aws_ecr_repository.repo.name
  policy                        = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Only keep 4 images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": ${var.number_of_images_to_keep_in_repo}
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
  count                         = var.create_lifecycle_policy ? 1 : 0
}