output "vpc_id" {
  value = module.networking.vpc_id
}

output "public_subnet_ids" {
  value = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.networking.private_subnet_ids
}

output "nat_gateway_ids" {
  value = module.networking.nat_gateway_ids
}

output "alb_security_group_id" {
  value = module.security.alb_security_group_id
}

output "ecs_task_security_group_id" {
  value = module.security.ecs_task_security_group_id
}

output "ecs_instance_security_group_id" {
  value = module.security.ecs_instance_security_group_id
}

output "ecr_repository_name" {
  value = module.ecr.repository_name
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "task_execution_role_arn" {
  value = module.iam.task_execution_role_arn
}

output "ecs_instance_role_name" {
  value = module.iam.ecs_instance_role_name

}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}

output "ecs_cluster_arn" {
  value = module.ecs.cluster_arn
}

output "ecs_capacity_provider_name" {
  value = module.ecs.capacity_provider_name
}

output "ecs_autoscaling_group_name" {
  value = module.ecs.autoscaling_group_name
}

output "ecs_task_definition_arn" {
  value = module.ecs.task_definition_arn
}

output "cloudwatch_log_group" {
  value = module.ecs.log_group_name
}

# ---------------------------------------------------------
# Stage 7 - Application Load Balancer
# ---------------------------------------------------------

output "alb_arn" {
  value = module.alb.alb_arn
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "alb_target_group_arn" {
  value = module.alb.target_group_arn
}

# ---------------------------------------------------------
# Stage 8 - ACM HTTPS
# ---------------------------------------------------------

output "acm_certificate_arn" {
  value = module.acm.certificate_arn
}

output "acm_certificate_status" {
  value = module.acm.certificate_status
}
