terraform {
  required_version = ">= 1.11"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Intentionally local state: this config creates the bucket that every other
  # env's remote state depends on, so it can't depend on that bucket itself.
}

provider "aws" {
  region = var.aws_region
}
