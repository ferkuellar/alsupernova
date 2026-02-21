#!/usr/bin/env bash
set -euo pipefail

echo "Destroying BACKEND..."
cd iac/terraform/backend
terraform destroy -auto-approve

echo "Destroying CORE (CloudFront + S3)..."
cd ../core
terraform destroy -auto-approve

echo "Done."