# modules/cache

Wraps [`terraform-aws-modules/elasticache/aws`](https://github.com/terraform-aws-modules/terraform-aws-elasticache)
(`~> 1.11`). Redis replication group, in-transit + at-rest encryption on by
default.

**Status: implemented.** Optional component: only instantiate from `envs/<env>`
if the project actually needs a cache.

## Intended inputs (contract)

- `name` (string)
- `node_type` (string) — small default for dev
- `vpc_id`, `subnet_ids` (from `modules/network`)
- `allowed_security_group_ids` (list(string))
- `num_cache_clusters` (number) — default `1` for dev, `>=2` for prod HA
- `tags` (map(string))

## Intended outputs

- `primary_endpoint_address`
- `reader_endpoint_address`

## Upstream reference

<https://registry.terraform.io/modules/terraform-aws-modules/elasticache/aws/latest>
