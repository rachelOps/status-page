variable "cluster_name" {
  description = "Name of the EKS Cluster"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS Node Group"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID to associate with the EKS nodes"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the EKS Node Group"
  type        = string
  default     = "t3.medium"
}

variable "desired_size" {
  description = "Desired number of nodes in the node group"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of nodes in the node group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of nodes in the node group"
  type        = number
  default     = 4
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {
    "Project" = "TeamB"
  }
}

