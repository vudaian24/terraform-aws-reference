data "aws_availability_zones" "available" {
  state = "available"
}

module "network" {
  source = "../../modules/network"

  name = "${var.project_name}-${var.environment}"
  cidr = var.vpc_cidr
  azs  = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  single_nat_gateway = true # dev: cost over HA

  tags = var.tags
}

# TODO(implementation phase): wire remaining modules once each is implemented.
# Sketch of the intended wiring:
#
# module "alb" {
#   source = "../../modules/alb"
#
#   name              = "${var.project_name}-${var.environment}"
#   vpc_id            = module.network.vpc_id
#   public_subnet_ids = module.network.public_subnet_ids
#   certificate_arn   = var.enable_custom_domain ? module.acm_dns[0].certificate_arn : null
#
#   tags = var.tags
# }
#
# module "ecs_service" {
#   count  = var.compute_platform == "ecs" ? 1 : 0
#   source = "../../modules/ecs-service"
#
#   name                   = "${var.project_name}-${var.environment}"
#   vpc_id                 = module.network.vpc_id
#   private_subnet_ids     = module.network.private_subnet_ids
#   alb_security_group_id  = module.alb.security_group_id
#   target_group_arn       = module.alb.target_group_arn
#   image                  = var.container_image
#
#   tags = var.tags
# }
#
# module "eks_cluster" {
#   count  = var.compute_platform == "eks" ? 1 : 0
#   source = "../../modules/eks-cluster"
#
#   name               = "${var.project_name}-${var.environment}"
#   vpc_id             = module.network.vpc_id
#   private_subnet_ids = module.network.private_subnet_ids
#
#   tags = var.tags
# }
#
# module "database" {
#   source = "../../modules/database"
#
#   identifier = "${var.project_name}-${var.environment}"
#   vpc_id     = module.network.vpc_id
#   subnet_ids = module.network.database_subnet_ids
#
#   tags = var.tags
# }
#
# module "cache" {
#   count  = var.enable_cache ? 1 : 0
#   source = "../../modules/cache"
#
#   name       = "${var.project_name}-${var.environment}"
#   vpc_id     = module.network.vpc_id
#   subnet_ids = module.network.private_subnet_ids
#
#   tags = var.tags
# }
#
# module "queue" {
#   count  = var.enable_queue ? 1 : 0
#   source = "../../modules/queue"
#
#   name = "${var.project_name}-${var.environment}"
#
#   tags = var.tags
# }
#
# module "static_site" {
#   source = "../../modules/static-site"
#
#   name = "${var.project_name}-${var.environment}-web"
#
#   tags = var.tags
# }
#
# module "acm_dns" {
#   count  = var.enable_custom_domain ? 1 : 0
#   source = "../../modules/acm-dns"
#
#   providers = { aws = aws.us_east_1 }
#
#   enable_custom_domain = var.enable_custom_domain
#   domain_name          = var.domain_name
#
#   tags = var.tags
# }
