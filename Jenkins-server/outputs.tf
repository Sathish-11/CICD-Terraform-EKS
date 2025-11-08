output "jenkins_public_ip" {
  description = "Public IP address of the Jenkins EC2 instance"
  value       = try(module.ec2_instance.public_ip, module.ec2_instance.public_ips[0], "")
}

output "jenkins_public_dns" {
  description = "Public DNS name of the Jenkins EC2 instance"
  value       = try(module.ec2_instance.public_dns, module.ec2_instance.public_dns_name, "")
}
