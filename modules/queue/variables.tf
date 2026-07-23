variable "name" {
  description = "Queue name."
  type        = string
}

variable "fifo_queue" {
  description = "Whether this is a FIFO queue."
  type        = bool
  default     = false
}

variable "max_receive_count" {
  description = "Number of receives before a message moves to the dead-letter queue."
  type        = number
  default     = 5
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
