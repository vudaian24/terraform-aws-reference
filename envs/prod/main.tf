data "aws_availability_zones" "available" {
  state = "available"
}

module "network" {
  source = "../../modules/network"

  name = "${var.project_name}-${var.environment}"
  cidr = var.vpc_cidr
  azs  = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  single_nat_gateway = false # prod: HA over cost

  tags = var.tags
}

# CloudFront aliases require the cert in us-east-1 regardless of stack
# region — modules/acm-dns has no provider alias of its own, so the whole
# module call is substituted onto the env's us_east_1-aliased provider (see
# modules/acm-dns/README.md for why a two-level configuration_alias was
# rejected).
module "acm_dns" {
  count  = var.enable_custom_domain ? 1 : 0
  source = "../../modules/acm-dns"

  providers = { aws = aws.us_east_1 }

  enable_custom_domain = var.enable_custom_domain
  domain_name          = var.domain_name
  route53_zone_id      = var.route53_zone_id

  tags = var.tags
}

module "alb" {
  source = "../../modules/alb"

  name              = "${var.project_name}-${var.environment}"
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids

  # Deliberately NOT wired to module.acm_dns's cert: that cert is issued in
  # us-east-1 for CloudFront, but an ALB listener needs a cert in its own
  # region (ap-northeast-1 here) — a us-east-1 cert would be rejected by the
  # ALB API. A real project wanting HTTPS on this ALB needs a second,
  # regionally-matched ACM cert; out of scope for this reference's single
  # acm-dns instantiation. See docs/NOTES.md.
  certificate_arn = null

  tags = var.tags
}

module "ecs_service" {
  count  = var.compute_platform == "ecs" ? 1 : 0
  source = "../../modules/ecs-service"

  name                  = "${var.project_name}-${var.environment}"
  vpc_id                = module.network.vpc_id
  private_subnet_ids    = module.network.private_subnet_ids
  alb_security_group_id = module.alb.security_group_id
  target_group_arn      = module.alb.target_group_arn
  image                 = var.container_image

  tags = var.tags
}

module "eks_cluster" {
  count  = var.compute_platform == "eks" ? 1 : 0
  source = "../../modules/eks-cluster"

  name               = "${var.project_name}-${var.environment}"
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids

  tags = var.tags
}

locals {
  # Whichever compute path is active exposes a security group id that the DB/
  # cache SGs should allow ingress from; the inactive path's module has
  # count = 0, so index [0] would error without this guard.
  compute_security_group_id = var.compute_platform == "ecs" ? module.ecs_service[0].task_security_group_id : module.eks_cluster[0].node_security_group_id
}

module "database" {
  source = "../../modules/database"

  identifier = "${var.project_name}-${var.environment}"
  vpc_id     = module.network.vpc_id
  subnet_ids = module.network.database_subnet_ids

  allowed_security_group_ids = [local.compute_security_group_id]

  multi_az            = true # prod: HA
  deletion_protection = true # prod: guard against accidental destroy

  tags = var.tags
}

module "cache" {
  count  = var.enable_cache ? 1 : 0
  source = "../../modules/cache"

  name       = "${var.project_name}-${var.environment}"
  vpc_id     = module.network.vpc_id
  subnet_ids = module.network.private_subnet_ids

  allowed_security_group_ids = [local.compute_security_group_id]

  num_cache_clusters = 2 # prod: HA (dev default stays 1)

  tags = var.tags
}

module "queue" {
  count  = var.enable_queue ? 1 : 0
  source = "../../modules/queue"

  name = "${var.project_name}-${var.environment}"

  tags = var.tags
}

module "static_site" {
  source = "../../modules/static-site"

  name = "${var.project_name}-${var.environment}-web"

  aliases             = var.enable_custom_domain ? [var.domain_name] : []
  acm_certificate_arn = var.enable_custom_domain ? module.acm_dns[0].certificate_arn : null

  tags = var.tags
}
