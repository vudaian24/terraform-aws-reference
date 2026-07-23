# TODO(implementation phase): wrap terraform-aws-modules/elasticache/aws ~> 1.11
#
# module "security_group" {
#   source  = "terraform-aws-modules/security-group/aws"
#   version = "~> 6.0"
#
#   name        = "${var.name}-redis"
#   vpc_id      = var.vpc_id
#   description = "Allow Redis access from application security groups"
#
#   ingress_with_source_security_group_id = [
#     for sg_id in var.allowed_security_group_ids : {
#       from_port                = 6379
#       to_port                  = 6379
#       protocol                 = "tcp"
#       source_security_group_id = sg_id
#     }
#   ]
#
#   tags = var.tags
# }
#
# module "redis" {
#   source  = "terraform-aws-modules/elasticache/aws"
#   version = "~> 1.11"
#
#   replication_group_id = var.name
#
#   engine         = "redis"
#   node_type      = var.node_type
#   num_cache_clusters = var.num_cache_clusters
#
#   subnet_group_name    = var.name
#   subnet_ids           = var.subnet_ids
#   security_group_ids   = [module.security_group.security_group_id]
#
#   at_rest_encryption_enabled = true
#   transit_encryption_enabled = true
#
#   tags = var.tags
# }
