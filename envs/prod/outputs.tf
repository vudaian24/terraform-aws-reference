output "vpc_id" {
  value = module.network.vpc_id
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "database_subnet_ids" {
  value = module.network.database_subnet_ids
}

# TODO(implementation phase): expose once the remaining modules are wired in main.tf.
#
# output "alb_dns_name"          { value = module.alb.alb_dns_name }
# output "cloudfront_domain_name" { value = module.static_site.distribution_domain_name }
# output "db_endpoint"           { value = module.database.db_instance_endpoint }
