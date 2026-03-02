variable "Environment" {
    description = "which environment we are deploying to"
    default = "dev"
}

variable "kubernetes_version" {
    description = "which version of kubernetes to run"
    default = "1.33"
}

variable "name" {
    description = "name of the eks cluster"
    default = "dev-cluster"
}

variable "vpc_id" {
  description = "VPC ID for EKS cluster"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for EKS cluster"
  type        = list(string)
}
