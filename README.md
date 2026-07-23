# terraform-aws-reference

Personal, product-agnostic Terraform reference repo for a typical web stack on AWS
(static SPA frontend, containerized API, database, cache, queue, optional CDN/DNS).
Built as thin wrappers around modules from
[terraform-aws-modules](https://github.com/terraform-aws-modules) — this repo does not
reimplement what upstream already provides.

> **Status: v0.1, in progress.** Directory structure, module contracts, and CI
> scaffolding are in place repo-wide. `modules/network` and `modules/gha-oidc`
> (+ `bootstrap/`) are implemented; `envs/dev`/`envs/prod` wire `network` for
> real (an end-to-end "smoke path" — data-sourced AZs, real outputs). Every
> other app-stack module (`static-site`, `database`, `cache`, `queue`, `alb`,
> `ecs-service`, `eks-cluster`, `acm-dns`) is still a commented-out TODO
> sketch. Nothing here has been `apply`-ed against real AWS. Do not point this
> at a real account until you've reviewed every module and env for your own
> use case.

## Why this repo exists

Reusable, versioned starting point for new projects — pin a specific tagged version
from a project repo, or copy a module directory and swap its `source` to the public
registry. Not tied to any one product's domain logic.

## How to reuse this in another project

> Don't pin a `ref=` for a module whose `main.tf` is still a commented-out
> TODO sketch — check that module's own README for its Status line first. As
> of v0.1 that's still `static-site`, `database`, `cache`, `queue`, `alb`,
> `ecs-service`, `eks-cluster`, `acm-dns`; `network` and `gha-oidc` are
> implemented. A git ref to a contract-only stub resolves and `init`s fine but
> creates zero resources, which is a confusing failure mode. Wait for a
> module's README to say "implemented" before pinning it into another
> project.

**Option A — pin by git ref (recommended for staying in sync with fixes):**

```hcl
module "network" {
  source = "git::https://github.com/vudaian24/terraform-aws-reference.git//modules/network?ref=v0.1.0"
  # ... inputs
}
```

**Option B — copy the module directory** into your project's `modules/` and change
its internal `source =` lines to point directly at the public registry
(`terraform-aws-modules/<name>/aws`) instead of relying on this repo at runtime.

## Repository layout

```
.
├── bootstrap/        # One-time setup: S3 bucket + state locking for remote state
├── modules/           # Thin wrappers around terraform-aws-modules, one concern each
├── envs/               # Per-environment root configs (dev, prod) wiring modules together
├── examples/            # Standalone example(s) using modules straight from the registry
├── docs/                 # Design notes / decisions
└── .github/workflows/     # CI (fmt/validate/plan) and manual apply (OIDC)
```

See each directory's own `README.md` for details.

## Module → upstream mapping & pinned versions

| Local module      | Upstream (terraform-aws-modules)                  | Pinned  |
|--------------------|----------------------------------------------------|---------|
| `network`          | `vpc/aws`                                           | `~> 6.0` |
| `static-site`      | `s3-bucket/aws` + `cloudfront/aws`                  | `~> 5.0` / `~> 6.0` |
| `database`         | `rds/aws`                                           | `~> 7.0` |
| `cache`            | `elasticache/aws`                                   | `~> 1.11` |
| `queue`            | `sqs/aws`                                           | `~> 5.0` |
| `alb`              | `alb/aws`                                           | `~> 10.0` |
| `ecs-service`      | `ecs/aws` (+ `ecs/aws//modules/service`)             | `~> 7.5` |
| `eks-cluster`      | `eks/aws`                                           | `~> 21.0` |
| `acm-dns`          | `acm/aws` + `route53/aws`                           | `~> 6.0` / `~> 6.0` |
| `gha-oidc`         | *(none — no upstream module for this exists)*       | n/a |

Versions above were the latest stable tags as of 2026-07-23. Bump deliberately —
don't float on `latest`. `gha-oidc` is hand-rolled IAM/OIDC resources, wired in
via `bootstrap/` rather than `envs/*` — see `modules/gha-oidc/README.md`.

## Prerequisites

- Terraform `>= 1.11` (`use_lockfile` shipped experimentally in 1.10 and
  stabilized in 1.11 — pin the floor to 1.11 so it's not accidentally run
  against the experimental behavior)
- AWS provider `~> 6.0` (bumped from `~> 5.0` once `modules/network` wired in
  `vpc/aws` v6, which requires provider `>= 6.28` — see `docs/NOTES.md`)
- An AWS account + credentials (local dev: SSO/profile; CI: OIDC — see
  `.github/workflows/`)

## Compute: ECS Fargate vs EKS

Both are scaffolded (`modules/ecs-service`, `modules/eks-cluster`) since the stack
they'll be reused for isn't fixed yet. Pick one per project — wiring both into the
same `envs/<env>` stack simultaneously is not the intended usage.

## Getting started (once modules are implemented)

1. Run `bootstrap/` once to create the remote state bucket (see `bootstrap/README.md`).
2. Copy `envs/dev/terraform.tfvars.example` → `terraform.tfvars` and
   `envs/dev/backend.hcl.example` → `backend.hcl`, fill in real values (never commit
   the real files — `.gitignore` already excludes them).
3. `cd envs/dev && terraform init -backend-config=backend.hcl`
4. `terraform plan`

## Security notes

- No real account IDs, domains, or secrets are committed anywhere in this repo —
  only placeholders (see `modules/acm-dns`).
- Database/master credentials are managed via AWS Secrets Manager
  (`manage_master_user_password`), never plaintext variables.
- CI apply uses GitHub OIDC → an AWS IAM role, not long-lived access keys.
- That role defaults to `PowerUserAccess` + a scoped IAM supplement (see
  `modules/gha-oidc/README.md`) — broad by design for the personal/sandbox
  account this repo targets, not meant as-is for a shared production account.

## Not using Terragrunt

Evaluated and intentionally skipped for this repo — Terragrunt earns its keep at
multi-repo/multi-team scale (DRY backend generation, dependency DAGs across many
units). For a single-person reference repo, plain Terraform with an `envs/<env>`
layout (per HashiCorp's own style guide) is simpler to read and copy. Revisit if
this repo ever needs to manage many near-identical stacks. See `docs/NOTES.md`.
