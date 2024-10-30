resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "redis-subnet-group"  # Name must be lowercase, use a valid naming convention
  subnet_ids = var.private_subnet_ids  # Reference your private subnets here

  tags = {
    Project = "TeamB"
  }
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "rs-redis-cluster"
  engine               = "redis"
  engine_version       = "6.x"
  node_type            = "cache.t3.micro"  # Update this as needed based on your performance requirements
  num_cache_nodes      = 1  # Can be adjusted based on your scaling needs
  parameter_group_name = "default.redis6.x"
  port                 = 6379
  security_group_ids   = [var.security_group_id]
  subnet_group_name    = aws_elasticache_subnet_group.redis_subnet_group.name

  tags = {
    Project = "TeamB"
  }
}

