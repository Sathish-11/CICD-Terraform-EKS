terraform {
  backend "s3" {
    bucket = "eks-s3-backnd-server"
    key    = "jenkins/terraform./tfstate"
    region = "ap-south-1"
  }
}
