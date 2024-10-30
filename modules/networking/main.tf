provider "aws" {
  region = var.aws_region
}

# Reference existing VPC
data "aws_vpc" "existing" {
  id = var.vpc_id
}

# Reference existing Security Group
data "aws_security_group" "existing" {
  id = var.security_group_id
}

# Reference existing Internet Gateway
data "aws_internet_gateway" "existing" {
  filter {
    name   = "attachment.vpc-id"
    values = [var.vpc_id]
  }
}

# Reference existing ECR Repository
data "aws_ecr_repository" "existing" {
  name = var.ecr_repository_name
}

# Reference existing subnets
data "aws_subnet" "private_subnets" {
  count = length(var.private_subnet_ids)
  id    = var.private_subnet_ids[count.index]
}

data "aws_subnet" "public_subnets" {
  count = length(var.public_subnet_ids)
  id    = var.public_subnet_ids[count.index]
}

data "aws_subnet" "cluster_subnets" {
  count = length(var.cluster_subnet_ids)
  id    = var.cluster_subnet_ids[count.index]
}

# Define the private route table
resource "aws_route_table" "private" {
  vpc_id = var.vpc_id
  tags = {
    Name    = "Private Route Table"
    Project = "TeamB"
  }
}

# Define the public route table
resource "aws_route_table" "public" {
  vpc_id = var.vpc_id
  tags = {
    Name    = "Public Route Table"
    Project = "TeamB"
  }
}

# Associate the private route table with private subnets
resource "aws_route_table_association" "private_association" {
  count          = length(var.private_subnet_ids)
  subnet_id      = element(var.private_subnet_ids, count.index)
  route_table_id = aws_route_table.private.id
}

# Associate the public route table with public subnets
resource "aws_route_table_association" "public_association" {
  count          = length(var.public_subnet_ids)
  subnet_id      = element(var.public_subnet_ids, count.index)
  route_table_id = aws_route_table.public.id
}

# Add route to the public route table for internet access
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = data.aws_internet_gateway.existing.id  # Reference existing IGW
}

# Create VPC endpoints for various AWS services
resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${var.aws_region}.dynamodb"
  route_table_ids = [aws_route_table.private.id]

  tags = {
    Name    = "DynamoDB VPC Endpoint"
    Project = "TeamB"
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${var.aws_region}.ecr.api"
  route_table_ids = [aws_route_table.private.id]

  tags = {
    Name    = "ECR API VPC Endpoint"
    Project = "TeamB"
  }
}

resource "aws_vpc_endpoint" "ecr_docker" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${var.aws_region}.ecr.dkr"
  route_table_ids = [aws_route_table.private.id]

  tags = {
    Name    = "ECR Docker VPC Endpoint"
    Project = "TeamB"
  }
}

resource "aws_vpc_endpoint" "codebuild" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${var.aws_region}.codebuild"
  route_table_ids = [aws_route_table.private.id]

  tags = {
    Name    = "CodeBuild VPC Endpoint"
    Project = "TeamB"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids = [aws_route_table.private.id]

  tags = {
    Name    = "S3 VPC Endpoint"
    Project = "TeamB"
  }
}

