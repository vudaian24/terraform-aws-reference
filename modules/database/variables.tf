variable "identifier" {
  description = "RDS instance identifier."
  type        = string
}

variable "engine_version" {
  description = "PostgreSQL engine version."
  type        = string
  default     = "16"
}

variable "instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t4g.micro"
}

variable "vpc_id" {
  description = "VPC ID from modules/network."
  type        = string
}

variable "subnet_ids" {
  description = "Database subnet IDs from modules/network."
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "Security group IDs allowed to connect (e.g. ECS task SG)."
  type        = list(string)
  default     = []
}

variable "multi_az" {
  description = "Enable Multi-AZ. false for dev, true for prod."
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Enable deletion protection. false for dev, true for prod."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
