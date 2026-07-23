variable "name" {
  description = "Name for the ALB and its resources."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID from modules/network."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs from modules/network."
  type        = list(string)
}

variable "certificate_arn" {
  description = "ACM certificate ARN for the HTTPS listener. Optional placeholder until a real domain exists."
  type        = string
  default     = null
}

variable "container_port" {
  description = "Port the target group forwards to / health-checks."
  type        = number
  default     = 3000
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
