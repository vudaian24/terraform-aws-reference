# modules/database

Wraps [`terraform-aws-modules/rds/aws`](https://github.com/terraform-aws-modules/terraform-aws-rds)
(`~> 7.0`). PostgreSQL by default. Master password managed by AWS Secrets Manager
(`manage_master_user_password`) — never a plaintext variable.

**Status: implemented.**

## Why RDS instance, not Aurora

Chose plain `rds/aws` over `rds-aurora/aws` for this reference repo: single
instance is simpler to reason about and cheaper to leave running as a dev
default, and it's the more common starting point. Aurora Serverless v2
(`terraform-aws-modules/rds-aurora/aws`) is a reasonable swap if a real project
wants scale-to-zero cost or multi-writer — same subnet/security-group inputs,
different resource internally. Not implemented here to avoid maintaining two
near-duplicate wrapper modules in a repo meant to stay small.

## Intended inputs (contract)

- `identifier` (string)
- `engine_version` (string) — default a recent PostgreSQL version
- `instance_class` (string) — small default for dev
- `vpc_id`, `subnet_ids` (from `modules/network` outputs)
- `allowed_security_group_ids` (list(string)) — e.g. ECS task SG
- `multi_az` (bool) — `false` for dev, `true` for prod
- `deletion_protection` (bool) — `false` for dev, `true` for prod
- `tags` (map(string))

## Intended outputs

- `db_instance_endpoint`
- `db_instance_master_user_secret_arn`

## Upstream reference

<https://registry.terraform.io/modules/terraform-aws-modules/rds/aws/latest>
