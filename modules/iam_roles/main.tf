resource "aws_iam_role" "eks_role" {
  name               = "EKS-Cluster-Role"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy.json
  lifecycle {
    #prevent_destroy = true
  }

  tags = var.tags
}

data "aws_iam_policy_document" "eks_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_node_group_role" {
  name               = "EKS-NodeGroup-Role"
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role_policy.json
  lifecycle {
    #prevent_destroy = true
  }

  tags = var.tags
}

data "aws_iam_policy_document" "eks_node_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "eks_worker_node" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  lifecycle {
    #prevent_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "eks_cni" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  lifecycle {
    #prevent_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  lifecycle {
    #prevent_destroy = true
  }
}

# Define the IAM policy for Cluster Autoscaler
resource "aws_iam_policy" "cluster_autoscaler_policy" {
  name        = "ClusterAutoscalerPolicy"
  description = "Policy for EKS Cluster Autoscaler"
  lifecycle {
    #prevent_destroy = true
  }

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:UpdateAutoScalingGroup",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeInstances",
          "ec2:DescribeTags",
          "ec2:DescribeLaunchConfigurations"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach the policy to the EKS node group role
resource "aws_iam_role_policy_attachment" "attach_cluster_autoscaler_policy" {
  policy_arn = aws_iam_policy.cluster_autoscaler_policy.arn
  lifecycle {
    #prevent_destroy = true
  }
  role       = aws_iam_role.eks_node_group_role.name
}

# Attach necessary policies to the EKS Cluster Role
resource "aws_iam_role_policy_attachment" "attach_eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  lifecycle {
    #prevent_destroy = true
  }
  role       = aws_iam_role.eks_role.name
}

resource "aws_iam_role_policy_attachment" "attach_eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  lifecycle {
    #prevent_destroy = true
  }
  role       = aws_iam_role.eks_role.name
}

resource "aws_iam_role_policy_attachment" "attach_cloudwatch_policy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  lifecycle {
    #prevent_destroy = true
  }
  role       = aws_iam_role.eks_role.name
}

