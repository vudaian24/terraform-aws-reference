# modules/ecs-service

Wraps [`terraform-aws-modules/ecs/aws`](https://github.com/terraform-aws-modules/terraform-aws-ecs)
(`~> 7.5`) — cluster + `ecs//modules/service` for one Fargate service. Attaches
to a target group from `modules/alb` (`create_attachment = false` on that side).

**Status:** skeleton — contract defined, upstream module calls not yet wired.
Alternative compute path to `modules/eks-cluster` — a given env wires one, not
both.

## Intended inputs (contract)

- `name` (string)
- `vpc_id`, `private_subnet_ids` (from `modules/network`)
- `alb_security_group_id`, `target_group_arn` (from `modules/alb`)
- `image` (string) — container image URI
- `container_port` (number)
- `cpu`, `memory` (number) — task size
- `desired_count`, `min_capacity`, `max_capacity` (number) — autoscaling
- `secrets` (map(string)) — env var name → Secrets Manager/SSM ARN
- `tags` (map(string))

## Intended outputs

- `cluster_arn`
- `service_id`
- `task_security_group_id`

## Upstream reference

<https://registry.terraform.io/modules/terraform-aws-modules/ecs/aws/latest>
