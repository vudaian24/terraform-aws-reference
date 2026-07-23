# modules/alb

Wraps [`terraform-aws-modules/alb/aws`](https://github.com/terraform-aws-modules/terraform-aws-alb)
(`~> 10.0`). HTTP→HTTPS redirect, HTTPS listener, target group with
`create_attachment = false` (ECS registers its own targets).

**Status:** skeleton — contract defined, upstream module call not yet wired.

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
