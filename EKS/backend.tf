terraform {
  backend "s3" {
    bucket = "eks-s3-backnd-server"
    key    = "EKS/terraform./tfstate"
    region = "ap-south-1"
  }
}

