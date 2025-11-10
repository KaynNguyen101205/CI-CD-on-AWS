output "jenkins_public_ip" {
  description = "Public IPv4 address of the Jenkins EC2 instance."
  value       = aws_instance.jenkins.public_ip
}

output "jenkins_public_dns" {
  description = "Public DNS host name of the Jenkins EC2 instance."
  value       = aws_instance.jenkins.public_dns
}

