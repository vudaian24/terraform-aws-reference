variable "aws_region" {
  description = "AWS region to create the state bucket in."
  type        = string
  default     = "ap-northeast-1"
}

variable "state_bucket_name" {
  description = <<-EOT
    Globally-unique S3 bucket name for Terraform remote state.
    S3 bucket names are global across all AWS accounts, so pick something
    project-specific, e.g. "yourorg-tfstate-<random-suffix>".
  EOT
  type        = string
}

variable "enable_gha_oidc" {
  description = "Whether to provision modules/gha-oidc (GitHub Actions OIDC role for terraform-apply.yml). Off by default so bootstrap works with just state_bucket_name until you're ready to wire up CI apply."
  type        = bool
  default     = false
}

variable "github_org" {
  description = "GitHub org/user for the OIDC trust policy. Required when enable_gha_oidc = true."
  type        = string
  default     = null

  validation {
    condition     = !var.enable_gha_oidc || var.github_org != null
    error_message = "github_org is required when enable_gha_oidc = true."
  }
}

variable "github_repo" {
  description = "GitHub repo name for the OIDC trust policy. Required when enable_gha_oidc = true."
  type        = string
  default     = null

  validation {
    condition     = !var.enable_gha_oidc || var.github_repo != null
    error_message = "github_repo is required when enable_gha_oidc = true."
  }
}

variable "iam_resource_prefix" {
  description = "Name prefix the GitHub Actions role's scoped IAM policy restricts role/policy management to — should match the project_name prefix envs/* use."
  type        = string
  default     = "reference-"
}

variable "tags" {
  description = "Common tags applied to bootstrap resources."
  type        = map(string)
  default = {
    Project   = "terraform-aws-reference"
    ManagedBy = "terraform"
    Layer     = "bootstrap"
  }
}
