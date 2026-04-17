locals {
  tags = {
    Project   = "homelab-graylog"
    ManagedBy = "terraform"
    Source    = "https://github.com/RobertYoung/homelab-graylog"
  }
}

resource "aws_ssm_parameter" "password_secret" {
  name        = "/homelab/graylog/password-secret"
  description = "Graylog password secret used to secure user passwords"
  type        = "SecureString"
  value       = "CHANGE_ME"

  tags = local.tags

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "root_password_sha2" {
  name        = "/homelab/graylog/root-password-sha2"
  description = "SHA2 hash of the Graylog root user password"
  type        = "SecureString"
  value       = "CHANGE_ME"

  tags = local.tags

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "backup_toolkit_private_key" {
  name        = "/homelab/graylog/backup-toolkit/private-key"
  description = "Private key for the Graylog backup toolkit mTLS client"
  type        = "SecureString"
  value       = "CHANGE_ME"

  tags = local.tags

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "backup_toolkit_private_cert" {
  name        = "/homelab/graylog/backup-toolkit/private-cert"
  description = "Client certificate for the Graylog backup toolkit mTLS client"
  type        = "SecureString"
  value       = "CHANGE_ME"

  tags = local.tags

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "backup_toolkit_ca_cert" {
  name        = "/homelab/graylog/backup-toolkit/ca-cert"
  description = "CA certificate used to verify the Graylog backup toolkit mTLS server"
  type        = "SecureString"
  value       = "CHANGE_ME"

  tags = local.tags

  lifecycle {
    ignore_changes = [value]
  }
}
