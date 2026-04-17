# Graylog Terraform Configuration

Manages the AWS SSM Parameter Store entries consumed by the `graylog` Ansible role.

## What This Creates

Five `SecureString` parameters in SSM (region `eu-west-1`):

- `/homelab/graylog/password-secret` — Graylog password secret
- `/homelab/graylog/root-password-sha2` — SHA2 hash of the Graylog root user password
- `/homelab/graylog/backup-toolkit/private-key` — mTLS client private key for the backup toolkit
- `/homelab/graylog/backup-toolkit/private-cert` — mTLS client certificate for the backup toolkit
- `/homelab/graylog/backup-toolkit/ca-cert` — CA certificate for the backup toolkit

All resources use `lifecycle { ignore_changes = [value] }`, so Terraform creates the parameters with a `CHANGE_ME` placeholder on first apply and then leaves the value alone. Set the real values out-of-band (see [Setting values](#setting-values)).

State is stored in S3: `s3://terraform-iamrobertyoung/projects/homelab-graylog/main/tfstate.json` (`eu-west-1`).

## Prerequisites

- Terraform >= 1.14.0
- aws-vault with profile `iamrobertyoung:home-assistant-production:p`

## Usage

```bash
cd terraform
aws-vault exec iamrobertyoung:home-assistant-production:p -- terraform init
aws-vault exec iamrobertyoung:home-assistant-production:p -- terraform plan
aws-vault exec iamrobertyoung:home-assistant-production:p -- terraform apply
```

## Setting values

After `terraform apply` has created the parameters, set the real secrets directly in SSM. Terraform will not overwrite them on subsequent applies.

```bash
aws-vault exec iamrobertyoung:home-assistant-production:p -- \
  aws ssm put-parameter --region eu-west-1 --overwrite \
  --name /homelab/graylog/password-secret \
  --type SecureString --value '<password-secret>'
```

## Consumption by Ansible

`playbooks/site.yml` reads the parameters via:

```yaml
graylog_password_secret: "{{ lookup('aws_ssm', '/homelab/graylog/password-secret', region='eu-west-1') }}"
```

## Files

- `terraform.tf` — S3 backend config
- `versions.tf` — Provider versions and region
- `main.tf` — SSM parameter resources
