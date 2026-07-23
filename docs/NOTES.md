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

## Remaining 8 modules implemented — real upstream schemas verified, not guessed

`database`, `cache`, `queue`, `static-site`, `acm-dns`, `alb`, `ecs-service`,
`eks-cluster` were all originally sketched as commented-out TODOs with
best-guess upstream variable/output names. Before uncommenting any of them,
fetched each pinned upstream module's real `variables.tf`/`outputs.tf` from
GitHub at the exact pinned tag (same empirical-verification approach used for
`modules/network`) rather than trusting the sketch. That surfaced several real
bugs the sketch would have hard-failed on at `terraform validate`/`plan`
time:

- **`security-group/aws` `~> 6.0` is a complete rewrite, not a rename.** The
  v4/v5 `ingress_with_source_security_group_id` (list of maps) API is gone
  entirely — v6 replaces it with `ingress_rules`/`egress_rules`
  (`map(object)`, keyed by rule name, with `protocol` → `ip_protocol` and
  `source_security_group_id` → `referenced_security_group_id`). Also renamed
  output `security_group_id` → `id`. Affects `modules/database` and
  `modules/cache`, both of which create their own security group this way.
- **`cloudfront/aws` doesn't manage the origin S3 bucket's policy.** Setting
  up `origin_access_control` only configures the CloudFront side of OAC —
  confirmed via the module's real `main.tf` (no `aws_s3_bucket_policy`
  resource exists in it, no reference to `cloudfront.amazonaws.com`
  anywhere). Without an explicit bucket policy granting
  `cloudfront.amazonaws.com` `s3:GetObject` conditioned on
  `AWS:SourceArn = <distribution arn>`, the bucket stays unreadable by
  CloudFront (403s). Added that policy explicitly in `modules/static-site`.
- **`acm/aws`'s `wait_for_validation` silently no-ops without
  `validation_method = "DNS"`.** The module only creates the Route53
  validation record and the `aws_acm_certificate_validation` resource when
  `validation_method != null` — the original sketch left it unset, which
  means `zone_id`/`wait_for_validation` would have been dead code. Added
  `validation_method = "DNS"` explicitly in `modules/acm-dns`.
- **`route53/aws` has no "attach to an existing zone ID" path.** Its
  `create_zone = false` mode re-derives a zone ID via a
  `data "aws_route53_zone"` lookup **by name**, not by an ID you already
  have. Since this repo already threads `route53_zone_id` through as an
  existing/looked-up value, adopting this module would just add a redundant
  second lookup. Dropped it — `acm/aws` creates its own validation records
  internally, no separate Route53 module needed. Root README's version table
  updated to stop listing `route53/aws` as an `acm-dns` dependency.
- **`ecs/aws//modules/service`'s `security_group_rules` doesn't exist.**
  Real v7.5 API splits it into `security_group_ingress_rules`/
  `security_group_egress_rules` (mirroring the `security-group` module's own
  v6 rewrite above), with `ip_protocol`/`referenced_security_group_id`
  instead of `protocol`/`source_security_group_id`. Also:
  `container_definitions` mixes camelCase ECS-API field names
  (`portMappings`, `containerPort`, `readonlyRootFilesystem`) with a
  snake_case module-added field (`enable_cloudwatch_logging`) — the sketch
  had guessed snake_case throughout. Root cluster module output is
  `cluster_arn`, not `arn`.
- **ALB `listeners` HTTP/HTTPS branching can't be a plain ternary between
  differently-shaped object literals.** Terraform rejects a conditional
  expression whose two branches are objects with different attribute keys
  ("Inconsistent conditional result types") — confirmed by a real
  `terraform validate` failure. Fixed by keeping one always-present `http`
  entry whose `forward`/`redirect` sub-attributes are null on whichever
  branch doesn't apply (null unifies fine against a single attribute's
  type), plus a separately-nullable `https` entry, filtered with
  `for ... if v != null` before handing the map to the module.
- **`eks/aws` v21 needed a `node_security_group_id` output added** (wasn't
  in the original stub's output list) so the EKS compute path has the same
  "security group to allow DB/cache ingress from" capability that
  `modules/ecs-service`'s `task_security_group_id` gives the ECS path.

All 10 modules (8 above + previously-implemented `network`/`gha-oidc`) now
validate directly in CI, and `envs/dev`/`envs/prod` validate the full wiring
together (both `compute_platform` branches, and `enable_cache`/`enable_queue`/
`enable_custom_domain` all set, exercised via `terraform validate` and a
`terraform plan` dry-run that got as far as the expected backend/credential
error, not a type error).

## ALB doesn't get the acm-dns cert — region mismatch, not an oversight

`modules/acm-dns`'s certificate is issued in us-east-1 (CloudFront's hard
requirement for aliases). An ALB listener needs a certificate in its *own*
region (ap-northeast-1 here) — the ALB API rejects a us-east-1 cert outright.
So `envs/*` wires the acm-dns cert only to `modules/static-site`
(CloudFront) and leaves the ALB's `certificate_arn` at `null` (HTTP-only,
per `modules/alb`'s existing null-cert fallback). A real project wanting
HTTPS on this ALB with a custom domain needs a second, regionally-matched
ACM certificate — out of scope for this reference's single acm-dns
instantiation; adding a second one (or a combined CloudFront-in-front-of-ALB
architecture that only needs the one us-east-1 cert) is a real option but a
genuine scope expansion, not a gap in what was asked for here.
