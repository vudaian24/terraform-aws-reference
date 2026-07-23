variable "enable_custom_domain" {
  description = "Opt-in flag. Must be explicitly set true by a real project — never on by default."
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Placeholder domain. Replace with a real domain when enable_custom_domain = true."
  type        = string
  default     = "example.internal"
}

variable "route53_zone_id" {
  description = "Existing Route53 hosted zone ID. No default — must be supplied by the consuming project."
  type        = string
  default     = null

  validation {
    condition     = !var.enable_custom_domain || var.route53_zone_id != null
    error_message = "route53_zone_id is required when enable_custom_domain = true — the ACM module needs it to create DNS validation records."
  }
}

variable "subject_alternative_names" {
  description = "Additional domain names to cover on the certificate."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
