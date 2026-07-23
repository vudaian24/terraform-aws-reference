output "role_arn" {
  description = "IAM role ARN for GitHub Actions to assume — set as the TF_APPLY_ROLE_ARN repo/environment variable."
  value       = aws_iam_role.this.arn
}

output "role_name" {
  value = aws_iam_role.this.name
}

output "oidc_provider_arn" {
  description = "The OIDC provider ARN in use (created here, or the pre-existing one passed via var.oidc_provider_arn)."
  value       = local.oidc_provider_arn
}
