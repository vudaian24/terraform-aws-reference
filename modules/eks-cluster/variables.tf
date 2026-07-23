variable "name" {
  description = "EKS cluster name."
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version."
  type        = string
  default     = "1.31"
}

variable "vpc_id" {
  description = "VPC ID from modules/network."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs from modules/network."
  type        = list(string)
}

variable "node_instance_types" {
  description = "Instance types for the managed node group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "min_size" {
  description = "Node group minimum size."
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Node group maximum size."
  type        = number
  default     = 3
}

variable "desired_size" {
  description = "Node group desired size."
  type        = number
  default     = 1
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
