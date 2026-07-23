# modules/acm-dns

Wraps [`terraform-aws-modules/acm/aws`](https://github.com/terraform-aws-modules/terraform-aws-acm)
(`~> 6.0`). DNS-validated ACM certificate.

**Status: implemented.** **No real domain is configured anywhere.**
`var.domain_name` defaults to the placeholder `example.internal`, and
`var.enable_custom_domain` defaults to `false` — a project using this module
must explicitly supply a real domain and opt in.

## Why not `terraform-aws-modules/route53/aws` too

The root README's version table originally listed this module as also
wrapping `route53/aws`, but that's not used here — checked its actual source
(v6.5.0) and it has no way to attach records to a hosted zone you already have
an ID for: its `create_zone = false` path re-derives a zone ID via a
`data "aws_route53_zone"` lookup **by name**, not by the ID you already pass
in. Adopting it here would mean a redundant second lookup for a zone ID this
module already receives as `var.route53_zone_id`. The DNS validation records
ACM needs are created by the `acm/aws` module itself (via its own
`aws_route53_record.validation` resource, gated on `validation_method =
"DNS"`) — no separate Route53 module involved. If a real project later needs
this module to also create an alias record pointing a domain at an ALB/
CloudFront distribution, add a plain `aws_route53_record` resource directly
against `var.route53_zone_id` rather than pulling in the registry module.

## CloudFront's us-east-1 requirement

CloudFront requires ACM certs for aliases to exist in `us-east-1` regardless
of where the rest of the stack lives. This module doesn't declare a provider
alias of its own — it just uses whatever `aws` provider its caller passes in.
The consuming env keeps a `provider "aws" { alias = "us_east_1" }` block and
substitutes it on the whole module call:

```hcl
module "acm_dns" {
  source    = "../../modules/acm-dns"
  providers = { aws = aws.us_east_1 }
  # ... inputs
}
```

A two-level alias (`configuration_aliases` on this module, passed through to
its own nested `acm` module call) was considered and rejected — it would
make `terraform validate` fail when this module is validated standalone (as
CI does directly), since there'd be no root-level provider block satisfying
the alias outside of a real calling env.

## Intended inputs (contract)

- `enable_custom_domain` (bool) — default `false`
- `domain_name` (string) — default `"example.internal"` placeholder
- `route53_zone_id` (string, optional) — existing hosted zone; **required
  when `enable_custom_domain = true`** (enforced by a variable `validation`
  block — the ACM module can't create DNS validation records without it)
- `subject_alternative_names` (list(string))
- `tags` (map(string))

## Outputs

- `certificate_arn`
- `validation_record_fqdns`

## Upstream reference

<https://registry.terraform.io/modules/terraform-aws-modules/acm/aws/latest>
