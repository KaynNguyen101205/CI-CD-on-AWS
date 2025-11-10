locals {
  terraform_private_key_path = "${path.module}/jenkinscicd.pem"
  terraform_public_key_path  = var.ssh_public_key_path != "" ? (substr(var.ssh_public_key_path, 0, 1) == "/" ? var.ssh_public_key_path : "${path.module}/${var.ssh_public_key_path}") : "${path.module}/jenkinscicd.pem.pub"
  ansible_private_key_path   = "${path.module}/../ansible/jenkinscicd.pem"
}

resource "tls_private_key" "jenkins" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "terraform_private_key" {
  content              = tls_private_key.jenkins.private_key_pem
  filename             = local.terraform_private_key_path
  file_permission      = "0400"
  directory_permission = "0700"
}

resource "local_file" "terraform_public_key" {
  content              = tls_private_key.jenkins.public_key_openssh
  filename             = local.terraform_public_key_path
  file_permission      = "0644"
  directory_permission = "0700"
}

resource "local_sensitive_file" "ansible_private_key" {
  content              = tls_private_key.jenkins.private_key_pem
  filename             = local.ansible_private_key_path
  file_permission      = "0400"
  directory_permission = "0700"
}

