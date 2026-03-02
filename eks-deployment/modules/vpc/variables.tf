variable "availability_zones" {
    description = "List of availability zones for the eks cluster"
    default = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "private_subnets" {
    description = "private subnet CIDR ranges for the eks cluster"
    type = list(string)
    default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "environment_name" {
    description = "Name of the environment"
    default = "dev"
}

variable "cidr" {
    description = "cidr range for the vpc"
    default = "10.0.0.0/16"
}
