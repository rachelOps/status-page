# modules/compute/outputs.tf

# Output for the EKS cluster name
output "cluster_name" {
  value = aws_eks_cluster.this.name
  description = "The name of the EKS cluster."
}

# Output for the EKS cluster endpoint
output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
  description = "The endpoint for the EKS cluster."
}

# Output for the EKS node group name
output "node_group_name" {
  value = aws_eks_node_group.this.node_group_name
  description = "The name of the EKS node group."
}

# Output for the node group's ARN
output "node_group_arn" {
  value = aws_eks_node_group.this.arn
  description = "The ARN of the EKS node group."
}

# Output for the node group's scaling configuration
output "node_group_scaling_config" {
  value = aws_eks_node_group.this.scaling_config
  description = "The scaling configuration for the EKS node group."
}

