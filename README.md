# Personal Project Infrastructure Bootstrap

This repository now includes the Terraform scaffolding to get the Jenkins lab ready and to automate the SSH keypair requested in tasks T0-01 through TF-02.

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

## Variable setup (TF-01)

1. Copy `terraform/terraform.tfvars.example` to `terraform/terraform.tfvars`.
2. Change `aws_region`, `aws_availability_zone`, and `allowed_cidr_ipv4` to match your account and laptop IP (`/32` mask only).
3. Keep `instance_type = "t2.micro"` and `root_volume_size = 20` to stay inside the free tier plan.
4. Run:

```
cd terraform
terraform validate
```

If `terraform validate` complains about the IP format, re-check that it ends with `/32` (for example `198.51.100.24/32`).

## Provision Jenkins host (TF-02)

With the variables in place you can create the real infrastructure:

```
cd terraform
terraform plan
terraform apply
```

The plan should show a new EC2 instance, a security group with two ingress rules (22 and 8080 to your `/32`), and the Jenkins key pair. After `terraform apply` finishes, note the outputs:

- `jenkins_public_ip`
- `jenkins_public_dns`

You will use these values in the Ansible inventory during `ANS-01`.

## Validation and cleanup

- Confirm the EC2 instance exists in the AWS console and sits in the AZ you picked.
- From your laptop run `nc -vz <public_ip> 22` and `nc -vz <public_ip> 8080` to be sure only these ports are open.
- When you are done experimenting, run `terraform destroy` from the `terraform` directory to avoid extra charges.

## Cost control and teardown (CLEAN-01)

- When you pause the lab, stop the EC2 instance so it does not burn hours:

  ```
  ./scripts/stop-jenkins.sh
  ```

- When you need Jenkins again, start it back up:

  ```
  ./scripts/start-jenkins.sh
  ```

  The scripts read the instance id from `terraform output`. Export `AWS_PROFILE=your-profile` first if you use a named profile.

- After you finish the project, destroy every resource so the account is clean:

  ```
  cd terraform
  terraform destroy
  ```

  Run this only once you are ready to remove the instance, key pair, and security group.

## Populate Ansible inventory (ANS-01)

1. Copy the Terraform output value for `jenkins_public_dns`.
2. Edit `ansible/inventory.yaml` and replace `replace-with-public-dns` with the real DNS or IP.
3. Make sure the private key copied earlier now exists at `ansible/jenkinscicd.pem` with `chmod 400`.
4. Run the connectivity check:

```
cd ansible
ansible -i inventory.yaml jenkins -m ping
```

Expected output: `"ping": "pong"` and `SUCCESS`. If it fails with `UNREACHABLE`, check that the security group allows your IP and the instance is running.

## Documentation bundle (DOC-01)

- Drop screenshots into `docs/screenshots/` using the suggested names from `docs/metrics.md`.
- After each successful Jenkins build copy the generated `metrics/image-size.csv` into the repo and append a short note in `docs/metrics.md`.
- Include Terraform apply, Ansible playbook recaps, Jenkins pipeline, Docker Hub tags, app homepage, and locked-down security group in the screenshot set.


