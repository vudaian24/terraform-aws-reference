output "db_instance_endpoint" {
  value = module.db.db_instance_endpoint
}

output "db_instance_master_user_secret_arn" {
  value = module.db.db_instance_master_user_secret_arn
}
