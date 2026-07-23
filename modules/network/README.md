# modules/network

Wraps [`terraform-aws-modules/vpc/aws`](https://github.com/terraform-aws-modules/terraform-aws-vpc)
(`~> 6.0`). 3-tier subnet layout (public / private / database), NAT gateway(s),
optional VPC endpoints and flow logs.

**Status: implemented.** `terraform init`/`validate` pass against the real
upstream module (verified with AWS provider `~> 6.0` — see `docs/NOTES.md`
for why the provider pin moved off `~> 5.0`). Not yet `plan`/`apply`-ed
against a real account.

Subnet CIDRs are derived from `var.cidr` via `cidrsubnet(var.cidr, 6, netnum)`
— private subnets take `netnum` 0..N-1, public 16..16+N-1, database
32..32+N-1 (verified with `terraform plan` in isolation before wiring this
in — the netnum offsets need a gap of at least `len(azs)`, which an earlier
draft of this sketch got wrong and would have failed at plan time). E.g. for
a `/16` VPC with 3 AZs: private `10.0.0.0/22`–`10.0.8.0/22`, public
`10.0.64.0/22`–`10.0.72.0/22`, database `10.0.128.0/22`–`10.0.136.0/22`. The
16-slot gap supports up to 16 AZs per tier. Fine for a reference default;
pass explicit subnet lists instead if a real project needs specific ranges.

## Inputs (contract)

- `name` (string) — VPC/name prefix
- `cidr` (string) — VPC CIDR block
- `azs` (list(string)) — availability zones to spread subnets across
- `single_nat_gateway` (bool) — `true` for dev (cost), `false` for prod (HA)
- `enable_flow_log` (bool) — also creates the CloudWatch log group + IAM role
  needed for it to actually work
- `enable_vpc_endpoints` (bool) — Gateway-type only (S3, DynamoDB); Interface
  endpoints (ECR, Secrets Manager, etc.) need a different resource shape and
  aren't supported by this variable
- `vpc_endpoint_services` (list(string)) — default `["s3", "dynamodb"]`;
  validated to only accept those two (the only Gateway-type services AWS
  offers) — passing anything else fails at `plan`, not silently at `apply`
- `tags` (map(string))

## Outputs

- `vpc_id`
- `private_subnet_ids`, `public_subnet_ids`, `database_subnet_ids`
- `database_subnet_group_name`
- `private_route_table_ids`, `public_route_table_ids` — consumed internally by
  the `vpc_endpoints` gateway-endpoint routes; also useful for a project that
  needs to add its own routes

## Upstream reference

<https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest>
