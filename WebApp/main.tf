module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  
  name = "WebApp-VPC"
  cidr = "10.0.0.0/16"
  
  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  
  enable_nat_gateway = true
  enable_vpn_gateway = true
  
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_launch_template" "WebApp_LT" {
  name_prefix   = "WebApp"
  image_id      = "ami-0ed26f8cab1bc3bdb"
  instance_type = "t2.micro"
  vpc_security_group_ids = [resource.aws_security_group.ec2.id]

}

resource "aws_autoscaling_group" "WebApp_ASG" {
  name                = "WebApp-ASG"
  vpc_zone_identifier = module.vpc.private_subnets  # FIXED: use subnets not AZs
  desired_capacity    = 1
  max_size            = 2
  min_size            = 0
  
  launch_template {
    id      = aws_launch_template.WebApp_LT.id
    version = "$Latest"
  }
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"  # CHANGED: Use version 8 instead of 9
  
  name               = "WebApp-ALB"
  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  
  security_groups = [aws_security_group.alb.id]  # CHANGED: Use separate SG
  
  target_groups = [  # CHANGED: List syntax for v8
    {
      name_prefix      = "webapp"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]
  
  http_tcp_listeners = [  # CHANGED: v8 listener syntax
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]
}

resource "aws_security_group" "alb" {
  name_prefix = "alb-sg"
  vpc_id      = module.vpc.vpc_id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }
}

resource "aws_security_group" "ec2" {
  name_prefix = "alb-sg"
  vpc_id      = module.vpc.vpc_id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_autoscaling_attachment" "WebApp_attachment" {
  autoscaling_group_name = aws_autoscaling_group.WebApp_ASG.name
  lb_target_group_arn    = module.alb.target_group_arns[0]  # CHANGED: v8 output
}
