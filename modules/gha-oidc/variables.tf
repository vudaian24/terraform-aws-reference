variable "name" {
  description = "Name for the IAM role GitHub Actions assumes."
  type        = string
  default     = "gha-terraform-apply"
}

variable "github_org" {
  description = "GitHub organization or user that owns the repo(s) allowed to assume this role."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name (without org) allowed to assume this role."
  type        = string
}

variable "github_environments" {
  description = <<-EOT
    GitHub Environment names whose deployments may assume this role. Trust is
    scoped to `repo:ORG/REPO:environment:NAME` — tighter than allowing any
    branch/ref, and lines up with GitHub Environments' own required-reviewers
    gate (see .github/workflows/terraform-apply.yml, which sets `environment:`
    per job). Requires the job that requests the OIDC token to declare
    `environment: <name>` — a token from a job without one won't match.
  EOT
  type        = list(string)
  default     = ["dev", "prod"]
}

variable "audience" {
  description = "OIDC audience GitHub Actions presents. sts.amazonaws.com is the AWS-documented default — don't change unless you know why."
  type        = string
  default     = "sts.amazonaws.com"
}

variable "create_oidc_provider" {
  description = <<-EOT
    Whether to create the token.actions.githubusercontent.com OIDC provider.
    AWS allows only ONE OIDC provider per URL per account — if this account
    already has one (e.g. from another project's Terraform), set this to
    false and pass its ARN via oidc_provider_arn instead of trying to create
    a second one (Terraform/AWS will error on a duplicate).
  EOT
  type        = bool
  default     = true
}

variable "oidc_provider_arn" {
  description = "Existing OIDC provider ARN to trust. Required (and only used) when create_oidc_provider = false."
  type        = string
  default     = null
}

variable "managed_policy_arns" {
  description = <<-EOT
    AWS managed policy ARNs attached to the role. Defaults to PowerUserAccess,
    which is broad — appropriate for a personal/sandbox account this repo is
    meant for, not a shared production account. Narrow this per real project.
  EOT
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/PowerUserAccess"]
}

variable "enable_scoped_iam_actions" {
  description = <<-EOT
    PowerUserAccess deliberately excludes iam:* (besides a few read-only/
    service-linked-role actions), but Terraform modules in this repo create
    IAM roles for ECS tasks, RDS monitoring, EKS, etc. When true, adds a
    supplemental policy granting IAM role/policy management — restricted to
    role names starting with iam_resource_prefix, and PassRole restricted to
    pass_role_service_principals — instead of unscoped iam:*.
  EOT
  type        = bool
  default     = true
}

variable "iam_resource_prefix" {
  description = "Name prefix the scoped IAM policy restricts role/policy management to. Should match the naming convention your envs use (e.g. your project_name variable's value, plus a trailing hyphen)."
  type        = string
  default     = "reference-"
}

variable "pass_role_service_principals" {
  description = "AWS service principals this role may PassRole to (scoped via iam:PassedToService), for the IAM roles Terraform creates for compute/services."
  type        = list(string)
  default = [
    "ecs-tasks.amazonaws.com",
    "ecs.amazonaws.com",
    "eks.amazonaws.com",
    "rds.amazonaws.com",
    "application-autoscaling.amazonaws.com",
  ]
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
