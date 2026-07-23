variable "name" {
  description = "Name prefix for the Redis replication group."
  type        = string
}

variable "node_type" {
  description = "ElastiCache node instance type."
  type        = string
  default     = "cache.t4g.micro"
}

variable "vpc_id" {
  description = "VPC ID from modules/network."
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs from modules/network."
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "Security group IDs allowed to connect (e.g. ECS task SG)."
  type        = list(string)
  default     = []
}

variable "num_cache_clusters" {
  description = "Number of cache clusters (nodes) in the replication group. 1 for dev, >=2 for prod HA."
  type        = number
  default     = 1
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
