module "cluster" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 7.5"

  cluster_name = var.name

  cluster_capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  create_task_exec_iam_role = true

  tags = var.tags
}

module "service" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "~> 7.5"

  name        = var.name
  cluster_arn = module.cluster.cluster_arn

  cpu    = var.cpu
  memory = var.memory

  create_task_exec_iam_role = false
  task_exec_iam_role_arn    = module.cluster.task_exec_iam_role_arn

  subnet_ids = var.private_subnet_ids

  # v7.x split the old combined ingress/egress "security_group_rules" map into
  # two separate maps modeled on aws_vpc_security_group_{ingress,egress}_rule
  # (ip_protocol/referenced_security_group_id/cidr_ipv4, not the old
  # protocol/source_security_group_id/cidr_blocks names).
  security_group_ingress_rules = {
    alb_ingress = {
      from_port                    = var.container_port
      to_port                      = var.container_port
      ip_protocol                  = "tcp"
      referenced_security_group_id = var.alb_security_group_id
    }
  }
  security_group_egress_rules = {
    egress_all = {
      from_port   = 0
      to_port     = 0
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  load_balancer = {
    service = {
      target_group_arn = var.target_group_arn
      container_name   = "app"
      container_port   = var.container_port
    }
  }

  enable_autoscaling       = true
  autoscaling_min_capacity = var.min_capacity
  autoscaling_max_capacity = var.max_capacity

  # container_definitions mixes camelCase ECS-API field names (portMappings,
  # containerPort, readonlyRootFilesystem) with snake_case module-added meta
  # fields (enable_cloudwatch_logging) — verified against the module's own
  # v7.5.0 source, not guessed.
  container_definitions = {
    app = {
      image     = var.image
      cpu       = var.cpu
      memory    = var.memory
      essential = true

      portMappings = [{ containerPort = var.container_port, protocol = "tcp" }]

      secrets = [for name, arn in var.secrets : { name = name, valueFrom = arn }]

      readonlyRootFilesystem    = true
      enable_cloudwatch_logging = true
    }
  }

  tags = var.tags
}
