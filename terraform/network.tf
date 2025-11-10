data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  # If user did not set specific AZ we just pick the first listed one.
  selected_availability_zone = var.aws_availability_zone != "" ? var.aws_availability_zone : data.aws_availability_zones.available.names[0]
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "default" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = local.selected_availability_zone

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

resource "aws_security_group" "jenkins" {
  name        = "${var.ssh_key_name}-jenkins-sg"
  description = "Allow Jenkins ports only from my laptop."
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Allow SSH from my /32."
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr_ipv4]
  }

  ingress {
    description = "Allow Jenkins web UI."
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr_ipv4]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-sg"
  }
}

