variable "name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "capacity_provider_name" {
  type = string
}

variable "launch_template_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "ecs_instance_security_group_id" {
  type = string
}

variable "ecs_instance_profile_name" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "asg_min_size" {
  type = number
}

variable "asg_desired_capacity" {
  type = number
}

variable "asg_max_size" {
  type = number
}

variable "container_name" {
  type = string
}

variable "container_port" {
  type = number
}

variable "container_cpu" {
  type = number
}

variable "container_memory" {
  type = number
}

variable "desired_count" {
  type = number
}

variable "log_group_name" {
  type = string
}

variable "log_retention_days" {
  type = number
}

variable "bootstrap_image" {
  type = string
}

variable "task_execution_role_arn" {
  type = string
}

variable "ecr_repository_url" {
  type = string
}

# ---------------------------------------------------------
# Stage 6 variables
# ---------------------------------------------------------

variable "aws_region" {
  type = string
}

variable "app_image" {
  type = string
}

variable "service_name" {
  type = string
}

variable "task_security_group_id" {
  type = string
}

variable "target_group_arn" {
  type = string
}
