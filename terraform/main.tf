terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

# Import existing VPC
data "aws_vpc" "existing_vpc" {
  id = "vpc-02868dfb0716e5728"
}

# Import existing private subnets
data "aws_subnet" "existing_private_subnets" {
  count = 3
  id    = element(["subnet-0c16d47a17a0cb199", "subnet-0691dd15533d87548", "subnet-0f70d69e8de30c5d8"], count.index)
}

# Import existing public subnets
data "aws_subnet" "existing_public_subnets" {
  count = 2
  id    = element(["subnet-0ebbc6840b8bab833", "subnet-056aa36b1061f8537"], count.index)
}

data "aws_internet_gateway" "RS_igw" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.existing_vpc.id]
  }
}

# Step 1: Create an Elastic IP for the NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

# Step 2: Create the NAT Gateway in a public subnet
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = data.aws_subnet.existing_public_subnets[0].id
  depends_on    = [data.aws_internet_gateway.RS_igw]  # Ensure the internet gateway exists first
}

# Step 3: Update Route Tables for Private Subnets

resource "aws_route_table" "private_route_tables" {
  vpc_id = data.aws_vpc.existing_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "Private Route Table"
  }

  lifecycle {
    prevent_destroy = true
  }
}


# Associate Route Tables with Private Subnets
resource "aws_route_table_association" "private_route_association" {
  count          = length(data.aws_subnet.existing_private_subnets)  # Loop through private subnets
  subnet_id      = element(data.aws_subnet.existing_private_subnets.*.id, count.index)  # Use data source
  route_table_id = aws_route_table.private_route_tables.id  # Correctly reference the route table
  lifecycle {
    prevent_destroy = true
  }
}





# Define the Security Group for RDS PostgreSQL
data "aws_security_group" "RDS-sg" {
  id = "sg-0993e0995433ee590"  # Existing RDS Security Group ID
}

data "aws_db_subnet_group" "rs-db-subnet-group" {
  name = "rs-db-subnet-group"  # RDS Subnet Group Name
}

# RDS instance
data "aws_db_instance" "existing_rds" {
  db_instance_identifier = "rsdatabase"  # Replace with your actual DB identifier
}


resource "aws_db_instance" "read_replicas" {
  count               = 2
  replicate_source_db = data.aws_db_instance.existing_rds.id
  instance_class     = "db.t3.small"
  depends_on         = [data.aws_db_instance.existing_rds]

  lifecycle {
    ignore_changes = [replicate_source_db]
  }
}

# Existing Subnet Group for Redis
data "aws_elasticache_subnet_group" "redis_subnet_group" {
  name = "rachelandshakedproject"  # Redis Subnet Group Name
}

# Import existing ElastiCache Redis replication group

data "aws_security_group" "redis_sg" {
  id = "sg-03a9d0da663855671"  # Existing Redis Security Group ID
}


data "aws_elasticache_replication_group" "existing_redis" {
  replication_group_id = "rs-redis"
}


# Define the Security Group for the EKS Cluster
resource "aws_security_group" "eks_cluster_sg" {
  name        = "rs-cluster-sg"
  description = "EKS Cluster Security Group"
  vpc_id      = data.aws_vpc.existing_vpc.id

  # Ingress rules
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Node-to-node communication
  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # Update with your VPC CIDR if necessary
  }

  # Egress rules (allow all outbound traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EKS Cluster Security Group"
  }
}


# Declare the IAM role for EKS nodes
resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      }
    ]
  })

  tags = {
    Name = "EKS Node Role"
  }
}

# Attach the IAM role policy to the EKS node role
resource "aws_iam_role_policy" "eks_node_policy" {
  name = "eksNodePolicy"
  role = aws_iam_role.eks_node_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:ListNodegroups",
          "eks:DescribeNodegroup"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.26.1"

  cluster_name    = "rs-cluster"
  cluster_version = "1.30"

  vpc_id          = data.aws_vpc.existing_vpc.id
  subnet_ids      = data.aws_subnet.existing_private_subnets[*].id

  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    monitoring_node_group = {
      desired_size = 2
      max_size     = 3
      min_size     = 1
      instance_type = "t3.small"
      subnet_ids   = data.aws_subnet.existing_private_subnets[*].id
      additional_security_group_ids = [aws_security_group.eks_cluster_sg.id]
      node_group_name = "rs-monitoring-ng"
    }

    application_node_group = {
      desired_size = 2
      max_size     = 3
      min_size     = 1
      instance_type = "t3.medium"
      node_group_name = "rs-application-ng"
    }
  }

  tags = {
    Name = "rs-eks-cluster"
    Project = "TeamB"
  }
}

output "vpc_id" {
  value = data.aws_vpc.existing_vpc.id
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_id" {
  value = module.eks.cluster_id
}

output "db_endpoint" {
  value = data.aws_db_instance.existing_rds.endpoint
}

output "read_replica_endpoints" {
  value = aws_db_instance.read_replicas[*].endpoint
}

output "elasticache_endpoint" {
  value = data.aws_elasticache_replication_group.existing_redis.configuration_endpoint_address
}

output "eks_security_group_id" {
  value = aws_security_group.eks_cluster_sg.id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.nat.id
}

output "rds_security_group_id" {
  value = data.aws_security_group.RDS-sg.id
}

output "redis_security_group_id" {
  value = data.aws_security_group.redis_sg.id
}

output "replication_group_details" {
  value = data.aws_elasticache_replication_group.existing_redis
}

output "rds_subnet_group_name" {
  value = data.aws_db_subnet_group.rs-db-subnet-group.name
}

output "internet_gateway_id" {
  value = data.aws_internet_gateway.RS_igw.id
}
