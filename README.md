# Personal Project Infrastructure Bootstrap

This repository now includes the Terraform scaffolding to get the Jenkins lab ready and to automate the SSH keypair requested in tasks T0-01 and T0-02.

## Terraform backend (T0-01)

- The Terraform backend is set to `local` so you can move fast on the free tier without paying for S3.
- If you later prefer S3, edit `terraform/main.tf` and swap the backend block with your bucket, key, and region. Run `terraform init -migrate-state` afterwards.

### First-time init

```
cd terraform
terraform init
```

`terraform init` should now work without extra flags. If you have multiple AWS profiles, adjust `var.aws_profile` in `terraform/variables.tf` or set `TF_VAR_aws_profile`.

## SSH keypair automation (T0-02)

Terraform handles the 4096-bit RSA keypair using the `tls_private_key` + `local_sensitive_file` resources so you do not have to run `ssh-keygen` manually. Running the apply below will:

- create `terraform/jenkinscicd.pem` with `0400` permissions,
- copy the same private key to `ansible/jenkinscicd.pem`,
- create `terraform/jenkinscicd.pem.pub` in OpenSSH format, and
- keep the key material in state so future applies stay idempotent.

```
cd terraform
terraform apply -auto-approve \
  -target=local_sensitive_file.terraform_private_key \
  -target=local_sensitive_file.ansible_private_key \
  -target=local_file.terraform_public_key
```

Afterwards double-check the permissions (WSL and Linux respect the `file_permission` settings; Windows may show the files as read-only).

The path to the public key is defined in `variables.tf` (`ssh_public_key_path`) so later modules can reference it when creating the EC2 key pair.

## Next steps

- Fill in `aws_region`, `aws_availability_zone`, and other variables in `terraform/variables.tf`.
- When you are ready to switch to an S3 backend, create the bucket first (`aws s3 mb`) and migrate the state as mentioned above.
- Proceed to backlog item `TF-01` once the keypair exists and Terraform init completes cleanly.

