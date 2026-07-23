# bootstrap

Creates the S3 bucket that every `envs/<env>` remote state backend depends on.
State locking uses the S3 backend's native `use_lockfile` (Terraform >= 1.11 —
stabilized in 1.11 after shipping experimental in 1.10; this repo's
`required_version` constraints are pinned accordingly) — no DynamoDB table
required.

This directory intentionally uses **local state** — it creates the bucket other
configs will store *their* state in, so it can't depend on that bucket itself.
Run it once per AWS account (or once per isolated state-bucket boundary you want),
then keep its own local `terraform.tfstate` somewhere safe (e.g. a password
manager / encrypted backup) since it is not itself stored remotely.

## Run once

```bash
cd bootstrap
terraform init
terraform plan  -var="state_bucket_name=yourorg-tfstate-<unique-suffix>"
terraform apply -var="state_bucket_name=yourorg-tfstate-<unique-suffix>"
```

Note the `state_bucket_name` output. Use it to fill in `backend.hcl` for each
env (see `envs/dev/backend.hcl.example`).

## Optional: GitHub Actions OIDC role (`modules/gha-oidc`)

Off by default (`enable_gha_oidc = false`) so the state bucket can be created
without deciding on CI up front. Turn on when you're ready to wire up
`.github/workflows/terraform-apply.yml`:

```bash
terraform apply \
  -var="state_bucket_name=yourorg-tfstate-<unique-suffix>" \
  -var="enable_gha_oidc=true" \
  -var="github_org=vudaian24" \
  -var="github_repo=terraform-aws-reference"
```

Take the `gha_apply_role_arn` output and set it as the `TF_APPLY_ROLE_ARN`
variable in the GitHub repo (or in each `dev`/`prod` GitHub Environment, for
per-environment reviewer gating). See `modules/gha-oidc/README.md` for the
design decisions (no thumbprint, environment-scoped trust, scoped IAM policy
instead of full admin, the one-OIDC-provider-per-account gotcha).

## What this does NOT do

- Does not create a DynamoDB lock table (not needed — see `docs/NOTES.md`).
- Does not create per-env state *keys* — each `envs/<env>/backend.tf` sets its
  own `key` so environments don't collide within the same bucket.
- Does not manage IAM permissions for who can read/write this bucket itself —
  that's a separate concern from the GitHub Actions apply role above; add a
  bucket policy / IAM role scoping for bucket access once you point this at a
  real account.
