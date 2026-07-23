module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = var.name
  cidr = var.cidr
  azs  = var.azs

  # newbits=6 gives 64 slots (netnum 0-63); a 16-slot gap between tiers
  # supports up to 16 AZs per tier before collision — comfortably more than
  # any AWS region offers.
  private_subnets  = [for i, az in var.azs : cidrsubnet(var.cidr, 6, i)]
  public_subnets   = [for i, az in var.azs : cidrsubnet(var.cidr, 6, i + 16)]
  database_subnets = [for i, az in var.azs : cidrsubnet(var.cidr, 6, i + 32)]

  create_database_subnet_group = true

  enable_nat_gateway = true
  single_nat_gateway = var.single_nat_gateway

  enable_flow_log                      = var.enable_flow_log
  create_flow_log_cloudwatch_log_group = var.enable_flow_log
  create_flow_log_cloudwatch_iam_role  = var.enable_flow_log

  tags = var.tags
}

module "vpc_endpoints" {
  count = var.enable_vpc_endpoints ? 1 : 0

  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 6.0"

  vpc_id = module.vpc.vpc_id

  endpoints = {
    for svc in var.vpc_endpoint_services : svc => {
      service         = svc
      service_type    = "Gateway"
      route_table_ids = concat(module.vpc.private_route_table_ids, module.vpc.public_route_table_ids)
    }
  }

  tags = var.tags
}
