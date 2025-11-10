instance_type = "t2.medium"
vpc_cidr      = "192.0.0.0/16"

public_subnets = ["192.0.1.0/24", "192.0.2.0/24", "192.0.3.0/24"]

private_subnets = ["192.0.4.0/24", "192.0.5.0/24", "192.0.6.0/24"]

jenkins_role_arn = "arn:aws:iam::003083321417:role/jenkins-eks-role"

cluster_creator_role_arn = "arn:aws:sts::003083321417:assumed-role/jenkins-eks-role/i-0f2f34972ed0d3701"

