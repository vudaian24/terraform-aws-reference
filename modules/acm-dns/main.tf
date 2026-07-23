# TODO(implementation phase): wrap terraform-aws-modules/acm/aws ~> 6.0 +
# terraform-aws-modules/route53/aws ~> 6.0
#
# CloudFront aliases require the cert in us-east-1 — add a provider alias in the
# consuming env (`provider "aws" { alias = "us_east_1" ... }`) and pass it in via
# `providers = { aws = aws.us_east_1 }` on the acm module call below.
#
# module "acm" {
#   count = var.enable_custom_domain ? 1 : 0
#
#   source  = "terraform-aws-modules/acm/aws"
#   version = "~> 6.0"
#
#   domain_name = var.domain_name
#   zone_id     = var.route53_zone_id
#
#   subject_alternative_names = var.subject_alternative_names
#
#   wait_for_validation = true
#
#   tags = var.tags
#
#   # providers = { aws = aws.us_east_1 }
# }
