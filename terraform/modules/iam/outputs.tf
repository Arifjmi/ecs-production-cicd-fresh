output "task_execution_role_arn" {
  value = aws_iam_role.task_execution.arn
}

output "task_execution_role_name" {
  value = aws_iam_role.task_execution.name
}

output "ecs_instance_role_arn" {
  value = aws_iam_role.ecs_instance.arn
}

output "ecs_instance_role_name" {
  value = aws_iam_role.ecs_instance.name
}

output "ecs_instance_profile_name" {
  value = aws_iam_instance_profile.ecs_instance.name
}

output "ecs_instance_profile_arn" {
  value = aws_iam_instance_profile.ecs_instance.arn
}
