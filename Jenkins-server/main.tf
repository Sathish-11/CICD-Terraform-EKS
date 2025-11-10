module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "jenkins-vpc"
  cidr = var.vpc_cidr

  azs            = data.aws_availability_zones.azs.names
  public_subnets = var.public_subnets

  enable_dns_hostnames    = true
  map_public_ip_on_launch = true

  tags = {
    Name      = "jenkins_vpc"
    Terraform = "true"
  }
  public_subnet_tags = {
    Name = "jenkins_subnet"
  }
}

#Create a Security Group for Jenkins Server
module "sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "jenkins-server-sg"
  description = "Security group for jenkins-server with HTTP ports open within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "Jenkins HTTP"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outbound traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  tags = {
    Name      = "jenkins_server_sg"
    Terraform = "true"
  }
}

#Create and import ssh key as pem file
resource "aws_key_pair" "jenkins-key" {
  key_name   = "jenk-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCzSS/wJRVOAgRAll0YpaNHAnKtW3IXYJjXdnp5yuqdN+VT6b2O8kqBRFdnAXHB6zE6+FrAP9RlKiCQAdVKZ3m2ZlH8AqJbAYYqaINQBnEEBiNHo47FbhqgyzZij5LCK9jO3OWL6ToV2yKvnT+YBrYIN0K9n7ZmYhapobVcareCBmITEVr4T74foRI4oZ9zSinixIFMREiVvm0bR0StyDMoc6uw1yNshvMk2h6MLJtu27/LwtZGv3Z7pUmg+BdQ9QwxOZcsaPCzWq3/ycl00Xhx1SlYJGzGI7f5NOn8orrLcfRrJdpMRQ8qbKXy4NJFbnTXnq4pzRqimtzPcf5UiM84ApoIpsEVIygR/5nX34SyctOFAj2zCDaeHIJD+qoB3qBHXWKNyNDyiBGdPmS2/eKLksIcb5sMlQd6Vn4NgwCkpTw/9JqailZHY88EjrDEx1dKgpfNh7YIkDMl/tInVzX6sYnSHQFZHesWvo9gO3/5vCrB6fmdwb/laWUmriK+Cx8= root@DESKTOP-G2GMGK6"
}

#Create an EC2 instance for Jenkins Server

module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "jenkins-server"

  instance_type          = var.instance_type
  ami                    = data.aws_ami.jenkins-ami.id
  key_name               = aws_key_pair.jenkins-key.key_name
  monitoring             = true
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [module.sg.security_group_id]
  user_data              = file("userdata.sh")
  iam_instance_profile   = aws_iam_instance_profile.jenkins_profile.name

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}