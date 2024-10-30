variable "aws_region" {
  description = "The AWS region to deploy the resources"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where resources will be created"
  type        = string
}

variable "security_group_id" {
  description = "The security group ID to associate with the resources"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "cluster_subnet_ids" {
  description = "List of cluster subnet IDs"
  type        = list(string)
}

variable "ecr_repository_name" {
  description = "The name of the ECR repository"
  type        = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "desired_size" {
  description = "Desired size of the EKS node group"
  type        = number
}

variable "max_size" {
  description = "Maximum size of the EKS node group"
  type        = number
}

variable "min_size" {
  description = "Minimum size of the EKS node group"
  type        = number
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}

variable "primary_db_allocated_storage" {
  description = "Allocated storage for the primary database."
  type        = number
  default     = 15
}

variable "primary_db_instance_class" {
  description = "Instance class for the primary database."
  type        = string
  default     = "db.t3.medium"
}

variable "db_username" {
  description = "Username for the RDS database."
  type        = string
}

variable "db_password" {
  description = "Password for the RDS database."
  type        = string
}

variable "db_name" {
  description = "Name of the primary database."
  type        = string
}

variable "primary_db_az" {
  description = "Availability zone for the primary database."
  type        = string
}

variable "read_replica_allocated_storage" {
  description = "Allocated storage for the read replicas."
  type        = number
  default     = 7 # Adjust based on your needs
}

variable "read_replica_instance_class" {
  description = "Instance class for the read replicas."
  type        = string
  default     = "db.t3.small" # Adjust based on your needs
}

variable "read_replica_azs" {
  description = "Availability zones for the read replicas."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"] # Adjust as needed
}

variable "security_group_ids" {
  description = "Security group IDs for the RDS instances."
  type        = list(string)
}
