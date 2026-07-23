# modules/alb

Wraps [`terraform-aws-modules/alb/aws`](https://github.com/terraform-aws-modules/terraform-aws-alb)
(`~> 10.0`). HTTP→HTTPS redirect, HTTPS listener, target group with
`create_attachment = false` (ECS registers its own targets).

**Status: implemented.**

The `listeners` map's HTTP/HTTPS branching couldn't be a plain ternary between
two differently-shaped object literals — Terraform rejects a conditional
whose branches are objects with different attribute keys ("Inconsistent
conditional result types"), confirmed by a real `terraform validate` failure
during implementation. Fixed by keeping one always-present `http` entry whose
`forward`/`redirect` sub-attributes are null on whichever branch doesn't
apply (null unifies fine against a single attribute's type), plus a
separately nullable `https` entry, filtered with a `for ... if v != null`
before handing the map to the module.

## Intended inputs (contract)

- `name` (string)
- `vpc_id`, `public_subnet_ids` (from `modules/network`)
- `certificate_arn` (string, optional — placeholder domain until `modules/acm-dns`
  is wired)
- `container_port` (number) — target group / health check port
- `tags` (map(string))

## Intended outputs

- `alb_arn`, `alb_dns_name`
- `target_group_arn` (for `modules/ecs-service` to attach to)
- `security_group_id`

## Upstream reference

<https://registry.terraform.io/modules/terraform-aws-modules/alb/aws/latest>
