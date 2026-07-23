module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 6.0"

  name        = "${var.identifier}-db"
  vpc_id      = var.vpc_id
  description = "Allow DB access from application security groups"

  # v6 rewrote ingress_with_* (list-of-maps) into a map(object) keyed by rule
  # name, with protocol -> ip_protocol and source_security_group_id ->
  # referenced_security_group_id. Verified against the module's real v6.0.0
  # source (no v5-style variable survived into v6 under any name).
  ingress_rules = {
    for sg_id in var.allowed_security_group_ids :
    "postgres-${sg_id}" => {
      from_port                    = 5432
      to_port                      = 5432
      ip_protocol                  = "tcp"
      referenced_security_group_id = sg_id
    }
  }

  tags = var.tags
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 7.0"

  identifier = var.identifier

  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = 20
  max_allocated_storage = 100

  db_name  = replace(var.identifier, "-", "_")
  username = "app"

  manage_master_user_password = true

  multi_az            = var.multi_az
  deletion_protection = var.deletion_protection

  create_db_subnet_group = true
  subnet_ids             = var.subnet_ids
  vpc_security_group_ids = [module.security_group.id]

  family               = "postgres16"
  major_engine_version = "16"

  tags = var.tags
}
