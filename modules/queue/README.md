# modules/queue

Wraps [`terraform-aws-modules/sqs/aws`](https://github.com/terraform-aws-modules/terraform-aws-sqs)
(`~> 5.0`). Standard queue + dead-letter queue by default.

**Status: implemented.** Optional component: only instantiate from `envs/<env>`
if the project actually needs a worker/queue.

## Intended inputs (contract)

- `name` (string)
- `fifo_queue` (bool) — default `false`
- `max_receive_count` (number) — retries before moving to DLQ, default `5`
- `tags` (map(string))

## Intended outputs

- `queue_url`, `queue_arn`
- `dead_letter_queue_url`, `dead_letter_queue_arn`

## Upstream reference

<https://registry.terraform.io/modules/terraform-aws-modules/sqs/aws/latest>
