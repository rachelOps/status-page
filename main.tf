provider "aws" {
  region = var.aws_region
}

# IAM Roles Module
module "iam_roles" {
  source = "./modules/iam_roles"
  tags   = var.tags
}

# Networking Module
module "networking" {
  source = "./modules/networking"
  aws_region             = var.aws_region
  vpc_id                 = var.vpc_id
  security_group_id      = var.security_group_id
  private_subnet_ids     = var.private_subnet_ids
  public_subnet_ids      = var.public_subnet_ids
  cluster_subnet_ids     = var.cluster_subnet_ids
  ecr_repository_name     = var.ecr_repository_name
}

# Compute Module
module "compute" {
  source = "./modules/compute"
  cluster_name  = var.cluster_name
  eks_role_arn  = module.iam_roles.eks_role.arn
  node_role_arn = module.iam_roles.eks_node_group_role.arn
  subnet_ids    = module.networking.cluster_subnet_ids
  desired_size  = var.desired_size
  max_size      = var.max_size
  min_size      = var.min_size
  common_tags   = var.tags
}

# Caching Module
module "caching" {
  source               = "./modules/caching"
  private_subnet_ids   = var.private_subnet_ids
  security_group_id    = var.security_group_id
}

resource "aws_db_instance" "rs-database" {
  identifier = "rs-database"  # Existing RDS instance identifier

  # Add additional configurations you want to manage
  tags = {
    Name    = "My Existing PostgreSQL RDS"
    Project = "TeamB"
  }

  # Note: You may not be able to change certain properties if they are already set in the existing RDS instance.
}


resource "aws_db_instance" "read_replica" {
  count                     = 2 # Number of read replicas to create
  allocated_storage         = var.read_replica_allocated_storage
  engine                   = "postgres"
  engine_version           = "13" # Specify your PostgreSQL version
  instance_class           = var.read_replica_instance_class
  db_subnet_group_name     = "rds-ec2-db-subnet-group-11" # Specify your DB subnet group
  vpc_security_group_ids   =  "sg-0dffd7c1287c4b6ae"
  replicate_source_db      = "rs-database" # Replace with your primary DB instance identifier
  availability_zone        = element(var.read_replica_azs, count.index)
  tags                     = var.tags

  # Optionally, you can add other parameters like storage type, backup retention, etc.
}


