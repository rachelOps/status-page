variable "security_group_id" {
  description = "The security group ID for the ElastiCache cluster."
  type        = string
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs where the ElastiCache cluster will be deployed."
  type        = list(string)
}

