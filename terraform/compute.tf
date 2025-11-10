data "aws_ami" "ubuntu_2204" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "jenkins" {
  key_name   = var.ssh_key_name
  public_key = tls_private_key.jenkins.public_key_openssh

  tags = {
    Name = "jenkins-key"
  }
}

resource "aws_instance" "jenkins" {
  ami           = data.aws_ami.ubuntu_2204.id
  instance_type = var.instance_type

  subnet_id                   = data.aws_subnet.default.id
  availability_zone           = local.selected_availability_zone
  vpc_security_group_ids      = [aws_security_group.jenkins.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.jenkins.key_name

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "jenkins-controller"
  }
}

