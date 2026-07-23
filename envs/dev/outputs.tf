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

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "cloudfront_domain_name" {
  value = module.static_site.distribution_domain_name
}

output "db_instance_endpoint" {
  value = module.database.db_instance_endpoint
}

output "queue_url" {
  value = var.enable_queue ? module.queue[0].queue_url : null
}

output "cache_primary_endpoint_address" {
  value = var.enable_cache ? module.cache[0].primary_endpoint_address : null
}
