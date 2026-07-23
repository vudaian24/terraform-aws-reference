# modules/gha-oidc

Hand-rolled (no upstream terraform-aws-modules equivalent exists) IAM OIDC
federation for GitHub Actions → AWS: one `aws_iam_openid_connect_provider` +
one `aws_iam_role` that `.github/workflows/terraform-apply.yml` assumes via
`aws-actions/configure-aws-credentials`, instead of long-lived access keys.

**Status: implemented** (not a TODO sketch, unlike the app-stack modules) —
this is small, self-contained identity/security plumbing, not a broad
multi-option wrapper, so it's built out now rather than left for later.

## Design decisions

**No `thumbprint_list`.** AWS validates GitHub's OIDC certificate against its
own trusted root CAs regardless of any configured thumbprint (as of the
[June 2023 GitHub/AWS OIDC update](https://github.blog/changelog/2023-06-27-github-actions-update-on-oidc-integration-with-aws/)),
and the Terraform AWS provider's `thumbprint_list` argument is optional.
Omitted here rather than hardcoding a value that would silently go stale.

**Trust scoped to GitHub Environments, not branches.** The `sub` claim
condition matches `repo:ORG/REPO:environment:NAME` for each name in
`var.github_environments` (default `["dev", "prod"]`) — not
`repo:ORG/REPO:ref:refs/heads/main`. This lines up with
`terraform-apply.yml`, whose job sets `environment: ${{ inputs.environment }}`
per run; GitHub only mints that claim when a job declares an `environment:`,
so it composes with GitHub Environments' own required-reviewers gate for a
real two-factor approval (OIDC identity + human approval) instead of trusting
any push to a branch.

**Permissions: `PowerUserAccess` + a scoped supplemental IAM policy, not
`AdministratorAccess`.** `PowerUserAccess` excludes almost all `iam:*` actions,
but the modules in this repo (`ecs-service`, `eks-cluster`, `database`, ...)
create IAM roles for their own resources (task execution roles, RDS monitoring
roles, IRSA roles). The supplemental policy grants role/policy management —
restricted by `resources` to role ARNs starting with `var.iam_resource_prefix`
— and `iam:PassRole` restricted by the `iam:PassedToService` condition to
`var.pass_role_service_principals`, instead of unscoped `iam:*`. Still broad
compared to a hand-tuned production policy — appropriate for the personal/
sandbox account this repo targets, not a shared production account. Narrow
`managed_policy_arns` for a real project.

**One OIDC provider per AWS account, not per project.** AWS rejects a second
`aws_iam_openid_connect_provider` for the same URL in the same account. If
this account already has a GitHub OIDC provider (from another Terraform
project), set `create_oidc_provider = false` and pass its ARN via
`oidc_provider_arn` — don't let two independent root configs both try to
create it.

## Usage

Call this from a run-once root, not per-env (identity is account-wide, not
per-environment) — `bootstrap/` already wires it in alongside the state
bucket:

```hcl
module "gha_oidc" {
  source = "../modules/gha-oidc"

  github_org           = "vudaian24"
  github_repo          = "terraform-aws-reference"
  github_environments  = ["dev", "prod"]
  iam_resource_prefix  = "reference-"

  tags = var.tags
}
```

After applying, set the output `role_arn` as the `TF_APPLY_ROLE_ARN` repo (or
environment) variable that `.github/workflows/terraform-apply.yml` reads, and
create matching GitHub Environments named `dev`/`prod` with required reviewers
if you want the approval gate.

## Inputs

See `variables.tf` — all documented inline (`github_org`, `github_repo`,
`github_environments`, `audience`, `create_oidc_provider`,
`oidc_provider_arn`, `managed_policy_arns`, `enable_scoped_iam_actions`,
`iam_resource_prefix`, `pass_role_service_principals`, `tags`).

## Outputs

- `role_arn` — the value to set as `TF_APPLY_ROLE_ARN`
- `role_name`
- `oidc_provider_arn`
