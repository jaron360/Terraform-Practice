output "private_subnets" {
    description = "private subnet IDs"
    value = module.vpc.private_subnets
}

output "public_subnets" {
    description = "public subnet IDs"
    value = module.vpc.public_subnets
}

output "vpc_endpoints_security_group_id" {
  value = aws_security_group.vpc_endpoints.id
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}
