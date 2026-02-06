module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  
  name = "WebApp-VPC"
  cidr = var.vpc_cidr_block
  
  azs             = var.availability_zones
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  
  enable_nat_gateway = true
  enable_vpn_gateway = true
  
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_launch_template" "WebApp_LT" {
  name_prefix   = "WebApp"
  image_id      = var.image_id
  instance_type = var.instance_type
  vpc_security_group_ids = [resource.aws_security_group.ec2.id]

}

resource "aws_autoscaling_group" "WebApp_ASG" {
  name                = "WebApp-ASG"
  vpc_zone_identifier = module.vpc.private_subnets
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
  version = "~> 8.0"
  name               = "WebApp-ALB"
  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups = [aws_security_group.alb.id]
  target_groups = [
    {
      name_prefix      = "webapp"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]
  http_tcp_listeners = [
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

#Attach autoscaling group to load balancer target group
resource "aws_autoscaling_attachment" "WebApp_attachment" {
  autoscaling_group_name = aws_autoscaling_group.WebApp_ASG.name
  lb_target_group_arn    = module.alb.target_group_arns[0]
}
