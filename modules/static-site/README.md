# modules/static-site

Wraps [`terraform-aws-modules/s3-bucket/aws`](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket)
(`~> 5.0`) + [`terraform-aws-modules/cloudfront/aws`](https://github.com/terraform-aws-modules/terraform-aws-cloudfront)
(`~> 6.0`). Private S3 bucket as CloudFront origin via Origin Access Control (OAC,
not the legacy OAI), SPA-friendly error responses (403/404 → `index.html`).

**Status:** skeleton — contract defined, upstream module calls not yet wired.

## Intended inputs (contract)

- `name` (string)
- `aliases` (list(string)) — CDN custom domains; leave empty to use only the
  default `*.cloudfront.net` domain
- `acm_certificate_arn` (string, optional) — required only if `aliases` is set
- `price_class` (string) — default `PriceClass_200`
- `tags` (map(string))

## Intended outputs

- `bucket_id`, `bucket_arn`
- `distribution_id`, `distribution_domain_name`

## Upstream reference

- <https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest>
- <https://registry.terraform.io/modules/terraform-aws-modules/cloudfront/aws/latest>
