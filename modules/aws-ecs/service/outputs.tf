output "service_arn" {
  description = "ARN of the ECS serice"
  value       = var.associate_alb || var.associate_nlb ? aws_ecs_service.main[0].id : aws_ecs_service.main_no_lb[0].id
}

output "service_name" {
  description = "Name of the ECS serice"
  value       = var.associate_alb || var.associate_nlb ? aws_ecs_service.main[0].name : aws_ecs_service.main_no_lb[0].name
}

output "ecs_security_group_id" {
  description = "Security Group ID assigned to the ECS tasks."
  value       = aws_security_group.ecs_sg.id
}

output "awslogs_group" {
  description = "Name of the CloudWatch Logs log group containers should use."
  value       = local.awslogs_group
}

output "awslogs_group_arn" {
  description = "ARN of the CloudWatch Logs log group containers should use."
  value       = aws_cloudwatch_log_group.main.arn
}

output "task_definition" {
  description = "Task definition"
  value       = var.associate_alb || var.associate_nlb ? aws_ecs_service.main[0].task_definition : aws_ecs_service.main_no_lb[0].task_definition
}
