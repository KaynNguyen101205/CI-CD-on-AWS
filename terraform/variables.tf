variable "aws_profile" {
  description = "AWS CLI profile to use when authenticating."
  type        = string
  default     = "default"
}

variable "aws_region" {
  description = "AWS region where infrastructure will be created."
  type        = string
  default     = "us-east-1"
}

variable "aws_availability_zone" {
  description = "Preferred availability zone within the chosen AWS region."
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "EC2 instance type for the Jenkins host."
  type        = string
  default     = "t3.small"
}

variable "root_volume_size" {
  description = "Size (GB) of the Jenkins host root EBS volume."
  type        = number
  default     = 20
}

variable "allowed_cidr_ipv4" {
  description = "CIDR block allowed to reach SSH/HTTP endpoints. Update with your /32."
  type        = string
  default     = "0.0.0.0/0"
}

variable "ssh_key_name" {
  description = "Name to assign to the EC2 key pair."
  type        = string
  default     = "jenkinscicd"
}

variable "ssh_public_key_path" {
  description = "Path to the Jenkins public key that Terraform will upload."
  type        = string
  default     = "terraform/jenkinscicd.pem.pub"
}

