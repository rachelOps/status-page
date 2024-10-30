# AWS Configuration
aws_region      = "us-east-1"

# EKS Cluster Configuration
cluster_name         = "RS-cluster"
node_group_name      = "RS-nodegroup"

# Node Group Scaling Configuration
desired_size    = 3                      # Desired number of nodes
max_size        = 4                      # Maximum number of nodes
min_size        = 2                      # Minimum number of nodes

# Existing Resources
vpc_id                = "vpc-02868dfb0716e5728" # Your existing VPC ID
security_group_id     = "sg-0d1c9a2bffc96083f"  # Your existing Security Group ID
subnet_ids            = [
    "subnet-0ebbc6840b8bab833",
    "subnet-0c16d47a17a0cb199",
    "subnet-0691dd15533d87548",
    "subnet-056aa36b1061f8537",
    "subnet-0f70d69e8de30c5d8"
]

# Route Table IDs
route_table_ids    = ["rtb-0b80d0660ab90ea48","rtb-004ee49acc9120a78", "rtb-0252c90e5607814f7"]

# IDs for the VPC endpoints
rds_endpoint_id        = "rs-database.cx248m4we6k7.us-east-1.rds.amazonaws.com"  # RDS VPC Endpoint ID
elasticache_endpoint_id = "rs-redis.7fftml.ng.0001.use1.cache.amazonaws.com:6379"
s3_endpoint_id          = "vpce-0de88ca114445f291"

private_subnet_ids = ["subnet-0c16d47a17a0cb199", "subnet-0691dd15533d87548", "subnet-0f70d69e8de30c5d8"]
cluster_subnet_ids = ["subnet-0c16d47a17a0cb199", "subnet-0691dd15533d87548"]
public_subnet_ids  = ["subnet-0ebbc6840b8bab833", "subnet-056aa36b1061f8537"]

# RDS Configuration
primary_db_allocated_storage = 20
primary_db_instance_class     = "db.t3.medium"
read_replica_allocated_storage = 7
read_replica_instance_class    = "db.t3.small"
security_group_ids             = ["sg-0dffd7c1287c4b6ae"]
db_username                     = "rsuser"
db_password                     = "rspassword"
db_name                         = "rs-database"
primary_db_az                  = "us-east-1b"  # Primary DB AZ
read_replica_azs               = ["us-east-1a", "us-east-1b"]  # Read Replica AZs
private_subnet_1_id            = "subnet-0c16d47a17a0cb199"  # Private Subnet 1 ID
private_subnet_2_id            = "subnet-0691dd15533d87548"  # Private Subnet 2 ID
private_subnet_3_id            = "subnet-0f70d69e8de30c5d8"  # Private Subnet 3 ID

# Endpoint Variables
internet_gateway_id   = "igw-0aaefd0722311570c"
ecr_repository_name    = "status-page-app"

# ECR Configuration
ecr_repository_uri   = "992382545251.dkr.ecr.us-east-1.amazonaws.com/status-page-app"

# Optional: Kubernetes and IAM Role Variables
kubernetes_version = "1.30"  # Desired Kubernetes version
eks_role_name = "EKS-Cluster-Role"
node_group_role_name = "EKS-NodeGroup-Role"

# Tags
tags = {
  Project = "TeamB"
  Owner   = "RachelAndShaked"
}

