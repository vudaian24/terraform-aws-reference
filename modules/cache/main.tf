module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 6.0"

  name        = "${var.name}-redis"
  vpc_id      = var.vpc_id
  description = "Allow Redis access from application security groups"

  # v6 rewrote ingress_with_* (list-of-maps) into a map(object) keyed by rule
  # name, with protocol -> ip_protocol and source_security_group_id ->
  # referenced_security_group_id. Verified against the module's real v6.0.0
  # source (no v5-style variable survived into v6 under any name).
  ingress_rules = {
    for sg_id in var.allowed_security_group_ids :
    "redis-${sg_id}" => {
      from_port                    = 6379
      to_port                      = 6379
      ip_protocol                  = "tcp"
      referenced_security_group_id = sg_id
    }
  }

  tags = var.tags
}

module "redis" {
  source  = "terraform-aws-modules/elasticache/aws"
  version = "~> 1.11"

  replication_group_id = var.name

  engine             = "redis"
  node_type          = var.node_type
  num_cache_clusters = var.num_cache_clusters

  subnet_group_name  = var.name
  subnet_ids         = var.subnet_ids
  security_group_ids = [module.security_group.id]

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  tags = var.tags
}
