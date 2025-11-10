#!/usr/bin/env bash

set -euo pipefail

# Simple helper to stop the Jenkins EC2 instance so AWS costs stay low.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TERRAFORM_DIR="${REPO_ROOT}/terraform"

if ! command -v aws >/dev/null 2>&1; then
  echo "aws cli not found. Please install awscli v2 before running this script."
  exit 1
fi

if ! command -v terraform >/dev/null 2>&1; then
  echo "terraform not found. Please install Terraform before running this script."
  exit 1
fi

cd "${TERRAFORM_DIR}"

INSTANCE_ID="$(terraform output -raw jenkins_instance_id)"

if [[ -z "${INSTANCE_ID}" ]]; then
  echo "Could not read Jenkins instance id from Terraform outputs."
  exit 1
fi

PROFILE_ARGS=()

if [[ -n "${AWS_PROFILE:-}" ]]; then
  PROFILE_ARGS+=(--profile "${AWS_PROFILE}")
fi

echo "Stopping Jenkins instance ${INSTANCE_ID}..."
aws ec2 stop-instances --instance-ids "${INSTANCE_ID}" "${PROFILE_ARGS[@]}"
aws ec2 wait instance-stopped --instance-ids "${INSTANCE_ID}" "${PROFILE_ARGS[@]}"
echo "Jenkins instance is now stopped."

