# AWS Web Application Infrastructure with Terraform

This Terraform configuration deploys a highly available web application infrastructure on AWS using Auto Scaling and Application Load Balancer.

## Architecture Overview

This infrastructure creates:
- VPC with public and private subnets across 3 availability zones
- Application Load Balancer (ALB) in public subnets
- Auto Scaling Group with EC2 instances in private subnets
- Security groups for ALB and EC2 instances
- NAT Gateway for outbound internet access from private subnets

## Components

### VPC Module
- **CIDR Block**: 10.0.0.0/16
- **Availability Zones**: us-east-1a, us-east-1b, us-east-1c
- **Private Subnets**: 10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24
- **Public Subnets**: 10.0.101.0/24, 10.0.102.0/24, 10.0.103.0/24
- **NAT Gateway**: Enabled for private subnet internet access
- **VPN Gateway**: Enabled

### Launch Template
- **AMI**: ami-0ed26f8cab1bc3bdb
- **Instance Type**: t2.micro
- **Security Group**: Allows HTTP traffic from ALB only

### Auto Scaling Group
- **Desired Capacity**: 1 instance
- **Min Size**: 0 instances
- **Max Size**: 2 instances
- **Deployment**: Instances launched in private subnets across all AZs

### Application Load Balancer
- **Type**: Application Load Balancer
- **Deployment**: Public subnets (internet-facing)
- **Listener**: HTTP on port 80
- **Target Group**: Routes traffic to EC2 instances on port 80
- **Health Checks**: HTTP health checks on port 80

### Security Groups

**ALB Security Group**:
- Ingress: Port 80 from 0.0.0.0/0 (internet)
- Egress: All traffic to 10.0.0.0/16 (VPC)

**EC2 Security Group**:
- Ingress: Port 80 from ALB security group only
- Egress: All traffic to internet


## Usage

### Initialize Terraform
```bash
terraform init
```

### Plan Infrastructure
```bash
terraform plan
```

### Deploy Infrastructure
```bash
terraform apply
```

### Destroy Infrastructure
```bash
terraform destroy
```
