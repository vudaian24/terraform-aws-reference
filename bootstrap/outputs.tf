output "state_bucket_name" {
  description = "Name of the S3 bucket to reference from each env's backend.hcl."
  value       = aws_s3_bucket.state.id
}

output "state_bucket_arn" {
  value = aws_s3_bucket.state.arn
}

output "gha_apply_role_arn" {
  description = "Set as the TF_APPLY_ROLE_ARN repo/environment variable for .github/workflows/terraform-apply.yml. Null when enable_gha_oidc = false."
  value       = var.enable_gha_oidc ? module.gha_oidc[0].role_arn : null
}
