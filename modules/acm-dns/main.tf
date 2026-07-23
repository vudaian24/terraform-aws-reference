# CloudFront aliases require the cert to exist in us-east-1 regardless of
# where the rest of the stack lives. This module makes no provider alias of
# its own — it just uses its default `aws` provider, and the consuming env
# substitutes that with a us-east-1-aliased provider on the whole module call:
#
#   module "acm_dns" {
#     source    = "../../modules/acm-dns"
#     providers = { aws = aws.us_east_1 }
#     ...
#   }
#
# Two levels of explicit provider aliasing (a `configuration_aliases` entry
# here plus an alias passed from the env) was considered and rejected: it
# would make `terraform validate` fail when this module is validated
# standalone (as CI does), since there'd be no root-level provider block to
# satisfy the alias outside of a real calling env.
module "acm" {
  count = var.enable_custom_domain ? 1 : 0

  source  = "terraform-aws-modules/acm/aws"
  version = "~> 6.0"

  domain_name = var.domain_name
  zone_id     = var.route53_zone_id

  subject_alternative_names = var.subject_alternative_names

  # Without this, the module never creates the Route53 validation record or
  # the aws_acm_certificate_validation resource (both are gated on
  # validation_method == "DNS"), so wait_for_validation silently never fires
  # and zone_id goes unused.
  validation_method   = "DNS"
  wait_for_validation = true

  tags = var.tags
}
