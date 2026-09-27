output "cluster_id" {
  value = aws_ecs_cluster.this.id
}

output "cluster_arn" {
  value = aws_ecs_cluster.this.arn
}

output "cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "capacity_provider_name" {
  value = aws_ecs_capacity_provider.this.name
}

output "autoscaling_group_name" {
  value = aws_autoscaling_group.ecs.name
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.bootstrap.arn
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.ecs.name
}
