module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "dev-vpc"
  cidr = var.cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnets

  enable_nat_gateway = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Terraform = "true"
    Environment = var.environment_name
  }
}

resource "aws_security_group" "vpc_endpoints" {
  name_prefix = "${var.environment_name}-vpc-endpoints-"
  description = "Security group for VPC endpoints"
  
  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.cidr]
  }
  
  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${var.environment_name}-vpc-endpoints-sg"
  }
}


module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 5.0"
  
  vpc_id = module.vpc.vpc_id
  
  # Reference the security group created above
  security_group_ids = [aws_security_group.vpc_endpoints.id]
  
  endpoints = {
    # ECR API - Interface endpoint
    ecr_api = {
      service             = "ecr.api"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      tags                = { Name = "${var.environment_name}-ecr-api-endpoint" }
    }
    
    # ECR DKR - Interface endpoint
    ecr_dkr = {
      service             = "ecr.dkr"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      tags                = { Name = "${var.environment_name}-ecr-dkr-endpoint" }
    }
    
    # EC2 - Interface endpoint
    ec2 = {
      service             = "ec2"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      tags                = { Name = "${var.environment_name}-ec2-endpoint" }
    }
    # EKS - Interface Endpoint
    eks = {
      service             = "eks"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      tags                = { Name = "${var.environment_name}-eks-endpoint" }
    }
    sts = {
      service             = "sts"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    }
  }
}
