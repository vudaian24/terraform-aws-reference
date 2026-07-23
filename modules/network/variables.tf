variable "name" {
  description = "Name prefix for the VPC and its resources."
  type        = string
}

variable "cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones to spread subnets across."
  type        = list(string)
}

variable "single_nat_gateway" {
  description = "Use a single shared NAT gateway (cheaper, less HA). Set false for prod."
  type        = bool
  default     = true
}

variable "enable_flow_log" {
  description = "Enable VPC flow logs to CloudWatch."
  type        = bool
  default     = false
}

variable "enable_vpc_endpoints" {
  description = "Create gateway VPC endpoints to cut NAT gateway data-transfer cost. Gateway-type only (S3, DynamoDB — see vpc_endpoint_services); Interface endpoints (ECR, Secrets Manager, etc.) need a different resource shape (subnet_ids + security_group_ids, no route_table_ids) and are out of scope for this variable — add them as a separate module call if a real project needs them."
  type        = bool
  default     = false
}

variable "vpc_endpoint_services" {
  description = "Gateway-type VPC endpoint services to create when enable_vpc_endpoints = true. Only \"s3\" and \"dynamodb\" are valid here — those are the only two AWS services offering a Gateway endpoint; anything else needs an Interface endpoint, which this variable does not support (see enable_vpc_endpoints)."
  type        = list(string)
  default     = ["s3", "dynamodb"]

  validation {
    condition     = alltrue([for s in var.vpc_endpoint_services : contains(["s3", "dynamodb"], s)])
    error_message = "vpc_endpoint_services only supports Gateway-type endpoints: \"s3\" and \"dynamodb\"."
  }
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
