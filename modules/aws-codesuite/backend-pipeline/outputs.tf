output "codebuild_role_id" {
  value = aws_iam_role.codebuild_role.id
}

output "codebuild_role_arn" {
  value = aws_iam_role.codebuild_role.arn
}

output "codebuild_role_name" {
  value = aws_iam_role.codebuild_role.name
}

output "codebuild_role_unique_id" {
  value = aws_iam_role.codebuild_role.unique_id
}


output "codebuild_project_id" {
  value = aws_codebuild_project.main.id
}

output "codebuild_project_arn" {
  value = aws_codebuild_project.main.arn
}

output "codebuild_project_name" {
  value = aws_codebuild_project.main.name
}



output "codepipeline_role_id" {
  value = aws_iam_role.codepipeline_role.id
}

output "codepipeline_role_arn" {
  value = aws_iam_role.codepipeline_role.arn
}

output "codepipeline_role_name" {
  value = aws_iam_role.codepipeline_role.name
}

output "codepipeline_role_unique_id" {
  value = aws_iam_role.codepipeline_role.unique_id
}


output "codepipeline_id" {
  value = aws_codepipeline.main.id
}

output "codepipeline_arn" {
  value = aws_codepipeline.main.arn
}

output "codepipeline_name" {
  value = aws_codepipeline.main.name
}