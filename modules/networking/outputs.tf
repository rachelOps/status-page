
output "private_route_table_id" {
  value = aws_route_table.private.id
}

output "public_route_table_id" {
  value = aws_route_table.public.id
}

output "internet_gateway_id" {
  value = data.aws_internet_gateway.existing.id
}

output "dynamodb_vpc_endpoint_id" {
  value = aws_vpc_endpoint.dynamodb.id
}

output "ecr_api_vpc_endpoint_id" {
  value = aws_vpc_endpoint.ecr_api.id
}

output "ecr_docker_vpc_endpoint_id" {
  value = aws_vpc_endpoint.ecr_docker.id
}

output "codebuild_vpc_endpoint_id" {
  value = aws_vpc_endpoint.codebuild.id
}

output "s3_vpc_endpoint_id" {
  value = aws_vpc_endpoint.s3.id
}

