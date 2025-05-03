#!/bin/bash
echo "Tearing down AWS Secrets Manager + Ansible project..."
cd terraform
terraform destroy -auto-approve
echo "Cleanup complete."
