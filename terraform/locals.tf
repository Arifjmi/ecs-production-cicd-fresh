locals {
  name = "${var.project_name}-${var.environment}"

  ecr_repository_name      = "${local.name}-app"
  ecs_cluster_name         = local.name
  ecs_service_name         = "${local.name}-service"
  target_group_name        = "fresh-prod-tg"
  alb_name                 = "fresh-prod-alb"
  log_group_name           = "/ecs/${local.name}"
  github_role_name         = "${local.name}-github-actions"
  task_execution_role_name = "${local.name}-task-execution-role"
  ecs_instance_role_name   = "${local.name}-ecs-instance-role"
  capacity_provider_name   = "fresh-production-capacity-provider"
  launch_template_name     = "${local.name}-ecs-lt"
}
