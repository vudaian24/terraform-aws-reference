# TODO(implementation phase): wrap terraform-aws-modules/rds/aws ~> 7.0
#
# module "security_group" {
#   source  = "terraform-aws-modules/security-group/aws"
#   version = "~> 6.0"
#
#   name        = "${var.identifier}-db"
#   vpc_id      = var.vpc_id
#   description = "Allow DB access from application security groups"
#
#   ingress_with_source_security_group_id = [
#     for sg_id in var.allowed_security_group_ids : {
#       from_port                = 5432
#       to_port                  = 5432
#       protocol                 = "tcp"
#       source_security_group_id = sg_id
#     }
#   ]
#
#   tags = var.tags
# }
#
# module "db" {
#   source  = "terraform-aws-modules/rds/aws"
#   version = "~> 7.0"
#
#   identifier = var.identifier
#
#   engine         = "postgres"
#   engine_version = var.engine_version
#   instance_class = var.instance_class
#
#   allocated_storage     = 20
#   max_allocated_storage = 100
#
#   db_name  = replace(var.identifier, "-", "_")
#   username = "app"
#
#   manage_master_user_password = true
#
#   multi_az                = var.multi_az
#   deletion_protection      = var.deletion_protection
#
#   create_db_subnet_group = true
#   subnet_ids             = var.subnet_ids
#   vpc_security_group_ids = [module.security_group.security_group_id]
#
#   family               = "postgres16"
#   major_engine_version = "16"
#
#   tags = var.tags
# }
