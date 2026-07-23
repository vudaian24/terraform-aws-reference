module "dlq" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "~> 5.0"

  name       = "${var.name}-dlq"
  fifo_queue = var.fifo_queue

  tags = var.tags
}

module "queue" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "~> 5.0"

  name       = var.name
  fifo_queue = var.fifo_queue

  redrive_policy = {
    deadLetterTargetArn = module.dlq.queue_arn
    maxReceiveCount     = var.max_receive_count
  }

  tags = var.tags
}
