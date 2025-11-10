---
title: Deployment Metrics
---

| Evidence | Notes |
| --- | --- |
| Terraform apply output (`terraform/terraform.tfstate` summary or console export) | Capture after successful `terraform apply`. |
| Ansible Jenkins install (`ansible-playbook -i inventory.yaml installation/installation.yaml`) | Screenshot of play recap. |
| Ansible Docker install (`ansible-playbook -i inventory.yaml installation/docker-install.yaml`) | Screenshot highlighting success. |
| Jenkins first green pipeline run | Screenshot of completed stages Clean → Checkout → Build → Push → Verify. |
| Docker Hub repository (`latest` and build-number tag) | Screenshot showing both tags, note listed sizes. |
| Application homepage running on EC2 (`http://<dns>:3000`) | Screenshot in browser. |
| Security group rules | Screenshot from AWS console showing only 22/8080 to your `/32`. |

## Image size tracking

`Jenkinsfile` creates `metrics/image-size.csv` every run containing the tags and sizes (MB). Upload or commit that CSV after each pipeline success to keep history.

## Suggested filename pattern

- `docs/screenshots/terraform-apply.png`
- `docs/screenshots/ansible-jenkins.png`
- `docs/screenshots/docker-install.png`
- `docs/screenshots/jenkins-pipeline.png`
- `docs/screenshots/dockerhub-tags.png`
- `docs/screenshots/app-home.png`
- `docs/screenshots/security-group.png`

Folder already has `.gitkeep` so Git tracks it even before screenshots are present. 

