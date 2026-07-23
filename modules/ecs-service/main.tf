# TODO(implementation phase): wrap terraform-aws-modules/ecs/aws ~> 7.5
#
# module "cluster" {
#   source  = "terraform-aws-modules/ecs/aws"
#   version = "~> 7.5"
#
#   cluster_name = var.name
#
#   cluster_capacity_providers = ["FARGATE", "FARGATE_SPOT"]
#
#   create_task_exec_iam_role = true
#
#   tags = var.tags
# }
#
# module "service" {
#   source  = "terraform-aws-modules/ecs/aws//modules/service"
#   version = "~> 7.5"
#
#   name        = var.name
#   cluster_arn = module.cluster.arn
#
#   cpu    = var.cpu
#   memory = var.memory
#
#   create_task_exec_iam_role = false
#   task_exec_iam_role_arn    = module.cluster.task_exec_iam_role_arn
#
#   subnet_ids = var.private_subnet_ids
#   security_group_rules = {
#     alb_ingress = {
#       type                     = "ingress"
#       from_port                = var.container_port
#       to_port                  = var.container_port
#       protocol                 = "tcp"
#       source_security_group_id = var.alb_security_group_id
#     }
#     egress_all = {
#       type        = "egress"
#       from_port   = 0
#       to_port     = 0
#       protocol    = "-1"
#       cidr_blocks = ["0.0.0.0/0"]
#     }
#   }
#
#   load_balancer = {
#     service = {
#       target_group_arn = var.target_group_arn
#       container_name   = "app"
#       container_port   = var.container_port
#     }
#   }
#
#   enable_autoscaling       = true
#   autoscaling_min_capacity = var.min_capacity
#   autoscaling_max_capacity = var.max_capacity
#
#   container_definitions = {
#     app = {
#       image     = var.image
#       cpu       = var.cpu
#       memory    = var.memory
#       essential = true
#
#       port_mappings = [{ containerPort = var.container_port, protocol = "tcp" }]
#
#       secrets = [for name, arn in var.secrets : { name = name, valueFrom = arn }]
#
#       readonly_root_filesystem  = true
#       enable_cloudwatch_logging = true
#     }
#   }
#
#   tags = var.tags
# }
