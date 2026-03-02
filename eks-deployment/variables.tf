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
