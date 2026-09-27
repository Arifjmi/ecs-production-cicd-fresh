data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id"
}

# ---------------------------------------------------------
# CloudWatch Log Group
# ---------------------------------------------------------

resource "aws_cloudwatch_log_group" "ecs" {
  name              = var.log_group_name
  retention_in_days = var.log_retention_days

  tags = {
    Name = var.log_group_name
  }
}

# ---------------------------------------------------------
# ECS Cluster
# ---------------------------------------------------------

resource "aws_ecs_cluster" "this" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = var.cluster_name
  }
}

# ---------------------------------------------------------
# ECS Launch Template
# ---------------------------------------------------------

resource "aws_launch_template" "ecs" {
  name = var.launch_template_name

  image_id = data.aws_ssm_parameter.ecs_ami.value

  instance_type = var.instance_type

  vpc_security_group_ids = [
    var.ecs_instance_security_group_id
  ]

  iam_instance_profile {
    name = var.ecs_instance_profile_name
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  user_data = base64encode(<<-EOF_USERDATA
    #!/bin/bash

    # ---------------------------------------------------------
    # ECS Agent Configuration
    # ---------------------------------------------------------

    cat > /etc/ecs/ecs.config <<'EOCONF'
    ECS_CLUSTER=${var.cluster_name}
    ECS_ENABLE_TASK_IAM_ROLE=true
    ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true
    ECS_LOGLEVEL=info
    EOCONF

    # ---------------------------------------------------------
    # Start ECS Agent AFTER cloud-init/cloud-final completes
    # ---------------------------------------------------------

    cat > /etc/systemd/system/ecs-after-cloud-init.service <<'EOSERVICE'
    [Unit]
    Description=Start ECS Agent after cloud-init
    After=cloud-final.service docker.service
    Requires=docker.service

    [Service]
    Type=oneshot
    ExecStart=/usr/bin/systemctl start ecs
    RemainAfterExit=yes

    [Install]
    WantedBy=multi-user.target
    EOSERVICE

    systemctl daemon-reload

    systemctl enable ecs-after-cloud-init.service
  EOF_USERDATA
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.name}-ecs-instance"
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name = "${var.name}-ecs-volume"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------
# ECS Auto Scaling Group
# ---------------------------------------------------------

resource "aws_autoscaling_group" "ecs" {
  name = "${var.name}-ecs-asg"

  min_size         = var.asg_min_size
  desired_capacity = var.asg_desired_capacity
  max_size         = var.asg_max_size

  vpc_zone_identifier = var.private_subnet_ids

  health_check_type = "EC2"

  protect_from_scale_in = true

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name}-ecs-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------
# ECS Capacity Provider
# ---------------------------------------------------------

resource "aws_ecs_capacity_provider" "this" {
  name = var.capacity_provider_name

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs.arn

    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 80
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 2
    }

    managed_termination_protection = "ENABLED"
  }

  tags = {
    Name = var.capacity_provider_name
  }
}

# ---------------------------------------------------------
# ECS Cluster Capacity Provider Association
# ---------------------------------------------------------

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = [
    aws_ecs_capacity_provider.this.name
  ]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.this.name
    weight            = 1
    base              = 0
  }
}

# ---------------------------------------------------------
# ECS Task Definition
#
# The existing Terraform resource is intentionally kept
# named "bootstrap" so existing Terraform outputs/state
# references do not need to change.
#
# The container runs the real ECR application image.
# ---------------------------------------------------------

resource "aws_ecs_task_definition" "bootstrap" {
  family = var.cluster_name

  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]

  cpu    = tostring(var.container_cpu)
  memory = tostring(var.container_memory)

  execution_role_arn = var.task_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.app_image
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      healthCheck = {
        command = [
          "CMD-SHELL",
          "wget -qO- http://localhost:3000/health || exit 1"
        ]

        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 10
      }

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = var.log_group_name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "app"
        }
      }
    }
  ])

  tags = {
    Name = "${var.name}-application-task"
  }
}

# ---------------------------------------------------------
# ECS Service
# ---------------------------------------------------------

resource "aws_ecs_service" "app" {
  name    = var.service_name
  cluster = aws_ecs_cluster.this.id

  task_definition = aws_ecs_task_definition.bootstrap.arn

  desired_count = var.desired_count

  # -------------------------------------------------------
  # Capacity Provider
  # -------------------------------------------------------

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.this.name
    weight            = 100
    base              = 1
  }

  # -------------------------------------------------------
  # ALB Target Group
  # -------------------------------------------------------

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  # -------------------------------------------------------
  # Deployment Configuration
  # -------------------------------------------------------

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  # -------------------------------------------------------
  # Network Configuration
  # -------------------------------------------------------

  network_configuration {
    subnets = var.private_subnet_ids

    security_groups = [
      var.task_security_group_id
    ]

    assign_public_ip = false
  }

  # -------------------------------------------------------
  # ECS Managed Tags
  # -------------------------------------------------------

  enable_ecs_managed_tags = true

  propagate_tags = "SERVICE"

  # -------------------------------------------------------
  # Lifecycle
  # -------------------------------------------------------

  lifecycle {
    ignore_changes = [
      task_definition
    ]
  }

  # -------------------------------------------------------
  # Dependencies
  # -------------------------------------------------------

  depends_on = [
    aws_ecs_cluster_capacity_providers.this
  ]
}
