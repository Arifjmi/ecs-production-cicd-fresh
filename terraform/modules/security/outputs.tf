output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "ecs_task_security_group_id" {
  value = aws_security_group.ecs_task.id
}

output "ecs_instance_security_group_id" {
  value = aws_security_group.ecs_instance.id
}
