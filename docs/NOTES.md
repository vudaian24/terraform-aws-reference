# Design notes / decisions

Short record of non-obvious decisions, so future changes don't accidentally
relitigate them without cause.

## State locking: native S3 lockfile, not DynamoDB

Terraform 1.10 introduced the S3 backend's `use_lockfile = true` as
experimental; 1.11 stabilized it (and deprecated `dynamodb_table`). All
`required_version` constraints in this repo are pinned to `>= 1.11` so nothing
here accidentally runs against the experimental 1.10 behavior. Chosen over the
older DynamoDB-table pattern to avoid a second piece of infrastructure to
bootstrap/maintain. Revisit only if a real project needs to support
Terraform < 1.11.

## No Terragrunt

Terragrunt's value (DRY backend generation, dependency DAG across many units,
centralized module catalog + separate "live" repo) shows up at multi-repo/
multi-team scale. This repo is single-person, single-repo, meant to be read and
copied — the extra tool/config layer isn't worth it here. Reconsider only if this
repo grows into managing many near-identical environments/stacks.

## Both ECS Fargate and EKS scaffolded

Product/stack isn't fixed yet, so both compute paths are kept as options
(`modules/ecs-service`, `modules/eks-cluster`). A real project should pick one —
wiring both into the same env stack at once is not the intended usage.

## ACM/Route53 kept as placeholders, not omitted

Domain modules (`modules/acm-dns`) are scaffolded with placeholder domains
(`example.internal`) and default `enable_custom_domain = false` so the module
contract exists for reuse, without ever encoding a real domain/account.

## GitHub Actions OIDC: implemented now, not left as a TODO sketch

Unlike the app-stack modules, `modules/gha-oidc` is fully implemented as of
v0.1 — it's small, self-contained identity/security plumbing (one OIDC
provider + one IAM role), not a broad multi-option wrapper, so there was no
reason to defer it. Key choices (see `modules/gha-oidc/README.md` for the
full rationale):

- No `thumbprint_list` — AWS validates GitHub's cert against its own trusted
  root CAs regardless of what's configured (June 2023 GitHub/AWS OIDC
  update). Hardcoding one would just be a value that goes stale silently.
- Trust scoped to GitHub *Environments* (`repo:ORG/REPO:environment:NAME`),
  not branches — composes with GitHub Environments' required-reviewers gate
  instead of trusting any push to `main`.
- `PowerUserAccess` + a supplemental policy scoped to `iam_resource_prefix`
  for the IAM role management Terraform modules here need (ECS task roles,
  RDS monitoring roles, etc.) — not `AdministratorAccess`. Still broad
  relative to a hand-tuned prod policy; that's an explicit tradeoff for a
  personal/sandbox account, documented as something to narrow per real
  project.
- Wired into `bootstrap/` (opt-in via `enable_gha_oidc`) rather than a new
  top-level root, since it's account-wide, run-once infra like the state
  bucket already there — not per-`envs/<env>`.

## Database: RDS instance, not Aurora

`modules/database` wraps `rds/aws`, not `rds-aurora/aws`. Single instance is
simpler to reason about and cheaper to leave running as a dev default; it's
also the more common starting point. Aurora Serverless v2 is a reasonable
swap for a real project wanting scale-to-zero cost or multi-writer — not
implemented here to avoid maintaining two near-duplicate wrapper modules in a
repo meant to stay small. Full rationale in `modules/database/README.md`.
Still optional to revisit — no pressure to add an Aurora variant unless a
project actually needs it.

## AWS provider bumped to `~> 6.0`

Discovered while implementing `modules/network` for real: `vpc/aws` v6.6.1
requires AWS provider `>= 6.28` (confirmed via its `versions.tf` on GitHub),
which is incompatible with this repo's original `~> 5.0` pin — `terraform
init` would hard-fail the moment the module was actually wired in, not just
sketched as a comment. Checked every other currently-pinned upstream module's
own provider floor before choosing a repo-wide number: highest was
`eks/aws`'s `>= 6.52`. `~> 6.0` satisfies all of them and the latest provider
release (`6.56.0` as of this check). Verified no breaking change in the v5→v6
provider major affects the specific resources already written
(`aws_s3_bucket*` in `bootstrap/`, `aws_iam_openid_connect_provider`/
`aws_iam_role*` in `gha-oidc`) before bumping repo-wide rather than only in
`modules/network`.

## envs/* wire network first, as a smoke path

`network` was implemented before any env actually called it — meaning CI's
`validate` job never touched the one real module in the repo (matrix only
covered `bootstrap`/`envs/*`, and `envs/*` main.tf was 100% comments). Fixed
by wiring `network` for real in both `envs/dev` and `envs/prod` (AZs via
`data.aws_availability_zones`, not the old hardcoded `"${region}a"` sketch —
that pattern silently breaks in regions/accounts where AZ letter mapping
doesn't line up) while leaving every other module's wiring commented. Also
added `modules/network` and `modules/gha-oidc` directly to the CI validate
matrix rather than relying solely on transitive coverage through
`bootstrap`/`envs/*` — that indirection would silently lose coverage if the
wiring changes later.

## Module version pins

Pinned to latest stable tag per module as of 2026-07-23 (checked via GitHub
Releases API, not guessed). See root `README.md` table. Bump deliberately.
