/* locals */
locals {
  key_name_prefix = "${var.environment}/${var.name_prefix}"
  secret_json = {
    "git-ssh-key" = "${tls_private_key.key.private_key_pem}"
  }
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "keypair" {
  key_name_prefix = local.key_name_prefix
  public_key      = tls_private_key.key.public_key_openssh
}

resource "aws_secretsmanager_secret" "secret_key" {
  name_prefix = local.key_name_prefix
  description = var.description
  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "secret_key_value" {
  secret_id     = aws_secretsmanager_secret.secret_key.id
  secret_string = jsonencode(local.secret_json)
    
}

/* vars */

variable "description" {
  default     = "ssh key"
  description = "Description of secret"
  type        = string
}

variable "name_prefix" {
  description = "Prefix to add to keypair/secret name"
  type        = string
}

variable "environment" {
  description = "Prefix to add to keypair/secret name"
  type        = string
  default     = "dev"
}

variable "tags" {
  default     = {}
  description = "Tags to add to supported resources"
  type        = map(string)
}


/* outputs */

output "key_name" {
  description = "Name of the keypair"
  value       = aws_key_pair.keypair.key_name
}

output "secrets_manager_secret_name" {
  description = "Name of the secretsManager secret name"
  value       = aws_secretsmanager_secret.secret_key.name
}

output "ssh_private_key" {
  value = tls_private_key.key.private_key_pem
  sensitive = true
}

output "ssh_public_key" {
  value = tls_private_key.key.public_key_openssh
  sensitive = true
}
