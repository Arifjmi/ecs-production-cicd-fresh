# ---------------------------------------------------------
# ECS Production CI/CD - Root Terraform Configuration
# ---------------------------------------------------------

module "networking" {
  source = "./modules/networking"

  name               = local.name
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones

  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

# ---------------------------------------------------------
# Security
# ---------------------------------------------------------

module "security" {
  source = "./modules/security"

  name   = local.name
  vpc_id = module.networking.vpc_id
}

# ---------------------------------------------------------
# ECR
# ---------------------------------------------------------

module "ecr" {
  source = "./modules/ecr"

  repository_name = local.ecr_repository_name
}

# ---------------------------------------------------------
# IAM
# ---------------------------------------------------------

module "iam" {
  source = "./modules/iam"

  task_execution_role_name = local.task_execution_role_name
  ecs_instance_role_name   = local.ecs_instance_role_name
}

# ---------------------------------------------------------
# ECS
# ---------------------------------------------------------

module "ecs" {
  source = "./modules/ecs"

  name                   = local.name
  cluster_name           = local.ecs_cluster_name
  capacity_provider_name = local.capacity_provider_name
  launch_template_name   = local.launch_template_name

  vpc_id = module.networking.vpc_id

  private_subnet_ids = module.networking.private_subnet_ids

  ecs_instance_security_group_id = module.security.ecs_instance_security_group_id

  ecs_instance_profile_name = module.iam.ecs_instance_profile_name

  instance_type        = var.ec2_instance_type
  asg_min_size         = var.asg_min_size
  asg_desired_capacity = var.asg_desired_capacity
  asg_max_size         = var.asg_max_size

  container_name = var.container_name
  container_port = var.container_port

  container_cpu    = var.ecs_cpu
  container_memory = var.ecs_memory

  desired_count = var.ecs_desired_count

  log_group_name     = local.log_group_name
  log_retention_days = var.log_retention_days

  bootstrap_image = var.bootstrap_image

  task_execution_role_arn = module.iam.task_execution_role_arn

  ecr_repository_url = module.ecr.repository_url

  # -------------------------------------------------------
  # Stage 6 - ECS Application
  # -------------------------------------------------------

  aws_region = var.aws_region

  app_image = "${module.ecr.repository_url}:v1"

  service_name = local.ecs_service_name

  task_security_group_id = module.security.ecs_task_security_group_id

  # -------------------------------------------------------
  # Stage 7 - ALB Target Group
  # -------------------------------------------------------

  target_group_arn = module.alb.target_group_arn
}

# ---------------------------------------------------------
# Application Load Balancer
# ---------------------------------------------------------

module "alb" {
  source = "./modules/alb"

  name = local.name

  vpc_id = module.networking.vpc_id

  public_subnet_ids = module.networking.public_subnet_ids

  alb_security_group_id = module.security.alb_security_group_id

  target_port = var.container_port

  health_check_path = "/health"

  target_group_name = local.target_group_name

  alb_name        = local.alb_name
  certificate_arn = module.acm.certificate_arn
}

# ---------------------------------------------------------
# ACM Certificate
# ---------------------------------------------------------

module "acm" {
  source = "./modules/acm"

  domain_name       = var.domain_name
  route53_zone_name = var.route53_zone_name
}

# ---------------------------------------------------------
# Route 53
# ---------------------------------------------------------

module "route53" {
  source = "./modules/route53"

  domain_name       = var.domain_name
  route53_zone_name = var.route53_zone_name

  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_zone_id
}
