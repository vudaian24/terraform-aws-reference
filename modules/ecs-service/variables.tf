variable "name" {
  description = "Name prefix for cluster/service."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID from modules/network."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs from modules/network."
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "ALB security group ID from modules/alb, allowed to reach the task SG."
  type        = string
}

variable "target_group_arn" {
  description = "ALB target group ARN from modules/alb."
  type        = string
}

variable "image" {
  description = "Container image URI."
  type        = string
}

variable "container_port" {
  description = "Container port exposed to the ALB."
  type        = number
  default     = 3000
}

variable "cpu" {
  description = "Fargate task vCPU units."
  type        = number
  default     = 512
}

variable "memory" {
  description = "Fargate task memory (MiB)."
  type        = number
  default     = 1024
}

variable "desired_count" {
  description = "Desired task count."
  type        = number
  default     = 1
}

variable "min_capacity" {
  description = "Autoscaling minimum task count."
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Autoscaling maximum task count."
  type        = number
  default     = 3
}

variable "secrets" {
  description = "Map of container env var name to Secrets Manager/SSM ARN."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
