# Call VPC module first
module "vpc" {
  source = "./modules/vpc/"
}

# Call EKS module and pass VPC ID from vpc module
module "eks" {
  source  = "./modules/eks/"

  name               = var.name
  kubernetes_version = var.kubernetes_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

}
