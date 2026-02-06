output "vpc_id" {
  description = "The ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "The IDs of the private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "The IDs of the public subnets"
  value       = module.vpc.public_subnets
}

output "aws_launch_template" {
    description = "The launch template ID"
    value = resource.aws_launch_template.WebApp_LT.id
}
