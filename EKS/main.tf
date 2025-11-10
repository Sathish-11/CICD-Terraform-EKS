#Create VPC for EKS cluster
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
  name    = "eks_cluster_vpc"
  cidr    = var.vpc_cidr

  azs             = data.aws_availability_zones.azs.names
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets


  enable_dns_hostnames = true
  enable_nat_gateway   = true
  single_nat_gateway   = true

  tags = {
    "kubernetes.io/cluster/eks-cluster" = "shared"
  }
  public_subnet_tags = {
    "kubernetes.io/cluster/eks-cluster" = "shared"
    "kubernetes.io/role/elb"            = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/eks-cluster" = "shared"
    "kubernetes.io/role/internal-elb"   = "1"
  }
}

# EKS 
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "eks-cluster"
  cluster_version = "1.29"

  cluster_endpoint_public_access = true
  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets

  # Grant Jenkins IAM role access to EKS (ADD THIS SECTION)
  enable_cluster_creator_admin_permissions = true

  access_entries = {
    jenkins = {
      principal_arn = var.jenkins_role_arn

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    nodes = {
      name           = "eks-nodes"
      instance_types = [var.instance_type]
      min_size       = 1
      max_size       = 3
      desired_size   = 2
      disk_size      = 20
    }
  }

  # Added recommended EKS addons
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}