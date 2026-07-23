variable "aws_region" {
  description = "AWS region for this environment."
  type        = string
  default     = "ap-northeast-1"
}

variable "project_name" {
  description = "Project name, used as a prefix for resource names."
  type        = string
  default     = "reference"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "prod"
}

variable "compute_platform" {
  description = "Which compute path to wire: \"ecs\" or \"eks\". A given env wires one, not both."
  type        = string
  default     = "ecs"

  validation {
    condition     = contains(["ecs", "eks"], var.compute_platform)
    error_message = "compute_platform must be \"ecs\" or \"eks\"."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of availability zones to spread subnets across."
  type        = number
  default     = 3
}

variable "container_image" {
  description = "Container image URI for the API service."
  type        = string
  default     = "public.ecr.aws/docker/library/nginx:stable"
}

variable "enable_cache" {
  description = "Whether to provision modules/cache (Redis)."
  type        = bool
  default     = false
}

variable "enable_queue" {
  description = "Whether to provision modules/queue (SQS)."
  type        = bool
  default     = false
}

variable "enable_custom_domain" {
  description = "Whether to provision modules/acm-dns with a real domain."
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Real domain name — only used when enable_custom_domain = true."
  type        = string
  default     = "example.internal"
}

variable "route53_zone_id" {
  description = "Existing Route53 hosted zone ID for domain_name. Required when enable_custom_domain = true (modules/acm-dns enforces this itself via a variable validation)."
  type        = string
  default     = null
}

variable "tags" {
  description = "Common tags applied to all resources in this environment."
  type        = map(string)
  default = {
    Project     = "terraform-aws-reference"
    Environment = "prod"
    ManagedBy   = "terraform"
  }
}
