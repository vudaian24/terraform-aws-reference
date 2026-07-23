# modules/acm-dns

Wraps [`terraform-aws-modules/acm/aws`](https://github.com/terraform-aws-modules/terraform-aws-acm)
(`~> 6.0`) + [`terraform-aws-modules/route53/aws`](https://github.com/terraform-aws-modules/terraform-aws-route53)
(`~> 6.0`). DNS-validated ACM certificate + Route53 records.

**Status:** skeleton — contract defined, upstream module calls not yet wired.
**No real domain is configured anywhere.** `var.domain_name` defaults to the
placeholder `example.internal`, and `var.enable_custom_domain` defaults to
`false` — a project using this module must explicitly supply a real domain and
opt in.

CloudFront requires ACM certs for aliases to exist in `us-east-1` regardless of
where the rest of the stack lives — this module's provider alias handles that
(see `main.tf` TODO).

## Intended inputs (contract)

- `enable_custom_domain` (bool) — default `false`
- `domain_name` (string) — default `"example.internal"` placeholder
- `route53_zone_id` (string, optional) — existing hosted zone; if null, module
  would need to create one (not recommended for a reference repo — zones are
  usually managed once, outside per-env stacks)
- `subject_alternative_names` (list(string))
- `tags` (map(string))

## Intended outputs

- `certificate_arn`
- `validation_record_fqdns`

## Upstream reference

- <https://registry.terraform.io/modules/terraform-aws-modules/acm/aws/latest>
- <https://registry.terraform.io/modules/terraform-aws-modules/route53/aws/latest>
