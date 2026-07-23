# modules/ecs-service

Wraps [`terraform-aws-modules/ecs/aws`](https://github.com/terraform-aws-modules/terraform-aws-ecs)
(`~> 7.5`) — cluster + `ecs//modules/service` for one Fargate service. Attaches
to a target group from `modules/alb` (`create_attachment = false` on that side).

**Status: implemented.** Alternative compute path to `modules/eks-cluster` — a
given env wires one, not both.

Fixed against the real `ecs/aws//modules/service` v7.5.0 source (not the
originally-sketched field names): root module output is `cluster_arn` (not
`arn`); the service submodule's security-group config is two separate maps
`security_group_ingress_rules`/`security_group_egress_rules` using
`ip_protocol`/`referenced_security_group_id`/`cidr_ipv4` (not a single
`security_group_rules` map with `type`/`protocol`/`source_security_group_id`/
`cidr_blocks`); and `container_definitions` mixes camelCase ECS-API fields
(`portMappings`, `containerPort`, `readonlyRootFilesystem`) with a snake_case
module-added field (`enable_cloudwatch_logging`).

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
