output "eks_role_arn" {
  value = aws_iam_role.eks_role.arn
}

output "cluster_autoscaler_policy_arn" {
  value = aws_iam_policy.cluster_autoscaler_policy.arn
}

