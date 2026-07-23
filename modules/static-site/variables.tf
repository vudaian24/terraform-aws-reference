variable "name" {
  description = "Name prefix for the bucket and distribution."
  type        = string
}

variable "aliases" {
  description = "Custom domain aliases for the CloudFront distribution. Empty = cloudfront.net domain only."
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "ACM cert ARN (us-east-1, required by CloudFront) for custom domains. Required only if aliases is non-empty."
  type        = string
  default     = null
}

variable "price_class" {
  description = "CloudFront price class."
  type        = string
  default     = "PriceClass_200"
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
