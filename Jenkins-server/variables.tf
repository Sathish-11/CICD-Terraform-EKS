variable "vpc_cidr" {
  description = "CIDR block for the vpc"
  type        = string
}
variable "public_subnets" {
  description = "List of public subnets"
  type        = list(string)
}
variable "instance_type" {
  description = "Instance type"
  type        = string
}
