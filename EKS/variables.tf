variable "instance_type" {
  description = "Instance_type"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR range for EKS_VPC"
  type        = string
}

variable "public_subnets" {
  description = "CIDR range for public subnet"
  type        = list(string)
}

variable "private_subnets" {
  description = "CIDR range for private subnet"
  type        = list(string)
}

# ADD THIS VARIABLE
variable "jenkins_role_arn" {
  description = "ARN of Jenkins IAM role for EKS access"
  type        = string
}