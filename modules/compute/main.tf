# modules/compute/main.tf

# EKS Cluster Resource
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.eks_role_arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  # Control plane logging
  enabled_cluster_log_types = ["api", "audit", "authenticator"]

  tags = merge(
    var.common_tags,
    {
      Name = "${var.cluster_name}-eks-cluster"
    }
  )
}

# Node Group Resource
resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = var.node_role_arn

  # Instance configurations for the node group
  instance_types = ["t3.medium"]
  disk_size      = 20

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  subnet_ids = var.subnet_ids

  tags = merge(
    var.common_tags,
    {
      Name = "${var.cluster_name}-node-group"
    }
  )
}

# Enable Cluster Autoscaler (for managing autoscaling of nodes)
resource "aws_autoscaling_group" "eks_asg" {
  desired_capacity     = var.desired_size
  max_size             = var.max_size
  min_size             = var.min_size
  vpc_zone_identifier  = var.subnet_ids
  launch_configuration = aws_launch_configuration.eks_launch_config.id

  tags = [
    {
      key                 = "Name"
      value               = "${var.cluster_name}-asg"
      propagate_at_launch = true
    },
  ]
}


