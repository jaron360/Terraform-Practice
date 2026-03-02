# EKS Cluster Deployment with Private Networking

This Terraform project deploys a fully private Amazon EKS cluster with VPC endpoints for secure, internet-free communication with AWS services.

## Architecture

- **VPC**: Custom VPC with private subnets across 3 availability zones
- **EKS Cluster**: Private endpoint only (no public access)
- **VPC Endpoints**: Interface and Gateway endpoints for AWS service communication
- **No NAT Gateway**: Cost-optimized design using VPC endpoints instead

## Features

- Private EKS cluster with no internet gateway or NAT gateway
- VPC endpoints for ECR, EC2, EKS, STS, and S3
- Managed node groups with auto-scaling
- EKS add-ons: CoreDNS, VPC CNI, kube-proxy, pod-identity-agent
- Cluster creator automatically added as admin

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate credentials
- AWS account with permissions to create VPC, EKS, and related resources

## Project Structure

```
deploy-eks/
├── main.tf                    # Root module configuration
├── variables.tf               # Root-level variables
├── outputs.tf                 # Root-level outputs
└── modules/
    ├── vpc/
    │   ├── vpc.tf            # VPC and VPC endpoints configuration
    │   ├── variables.tf      # VPC module variables
    │   └── outputs.tf        # VPC outputs (vpc_id, subnets, etc.)
    └── eks/
        ├── eks.tf            # EKS cluster configuration
        ├── variables.tf      # EKS module variables
        └── outputs.tf        # EKS outputs
```

## Configuration

### Root Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `name` | EKS cluster name | `dev-cluster` |
| `kubernetes_version` | Kubernetes version | `1.33` |
| `Environment` | Environment name | `dev` |

### VPC Module Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `cidr` | VPC CIDR block | `10.0.0.0/16` |
| `availability_zones` | AZs for subnets | `["us-west-2a", "us-west-2b", "us-west-2c"]` |
| `private_subnets` | Private subnet CIDRs | `["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]` |
| `environment_name` | Environment name | `dev` |

### VPC Endpoints

The following VPC endpoints are configured:

**Interface Endpoints:**
- `ecr.api` - ECR API operations
- `ecr.dkr` - ECR Docker registry
- `ec2` - EC2 API operations
- `eks` - EKS API operations
- `sts` - AWS STS for IAM authentication

**Gateway Endpoint:**
- `s3` - S3 access for ECR image layers (required for nodes to join cluster)

## Usage

### 1. Initialize Terraform

```bash
cd deploy-eks
terraform init
```

### 2. Review the Plan

```bash
terraform plan
```

### 3. Deploy the Infrastructure

```bash
terraform apply
```

### 4. Configure kubectl

After deployment, update your kubeconfig:

```bash
aws eks update-kubeconfig --name dev-cluster --region us-west-2
```

### 5. Verify Node Status

```bash
kubectl get nodes
```

## Customization

### Change Cluster Name

```hcl
# In variables.tf or via command line
terraform apply -var="name=my-cluster"
```

### Change Kubernetes Version

```hcl
terraform apply -var="kubernetes_version=1.31"
```

### Modify Node Group Configuration

Edit `modules/eks/eks.tf`:

```hcl
eks_managed_node_groups = {
  dev-nodes = {
    ami_type       = "AL2023_x86_64_STANDARD"
    instance_types = ["m5.xlarge"]
    
    min_size     = 2
    max_size     = 4
    desired_size = 2
  }
}
```

### Add Public Subnets

If you need public subnets, modify `modules/vpc/vpc.tf`:

```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  
  # ... existing config ...
  
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  
  # Enable NAT gateway if needed
  enable_nat_gateway = true
  single_nat_gateway = true
}
```

## Important Notes

### Private Cluster Considerations

- **No Internet Access**: Nodes cannot reach the internet without NAT gateway
- **VPC Endpoints Required**: All AWS service communication goes through VPC endpoints
- **ECR Access**: S3 gateway endpoint is critical for pulling container images
- **kubectl Access**: You need VPN or Direct Connect to access the cluster API


### Security

- Cluster endpoint is private only
- All traffic stays within AWS network
- Security group restricts endpoint access to VPC CIDR
- DNS resolution enabled for transparent service access


## Cleanup

To destroy all resources:

```bash
terraform destroy
```

## References

- [Terraform AWS VPC Module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws)
- [Terraform AWS EKS Module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws)
- [AWS VPC Endpoints](https://docs.aws.amazon.com/vpc/latest/privatelink/vpc-endpoints.html)
- [EKS Private Clusters](https://docs.aws.amazon.com/eks/latest/userguide/private-clusters.html)
