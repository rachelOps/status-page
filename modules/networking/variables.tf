variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the existing VPC"
  type        = string
}

variable "security_group_id" {
  description = "The ID of the existing Security Group"
  type        = string
}

variable "ecr_repository_name" {
  description = "The name of the existing ECR Repository"
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

