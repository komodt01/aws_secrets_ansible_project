# AWS Secrets Manager + Ansible Automation Project

This project demonstrates how to securely retrieve secrets from AWS Secrets Manager using Ansible, with the supporting AWS infrastructure deployed using Terraform. The design reflects real-world secret retrieval patterns, IAM least-privilege access, and infrastructure automation.

The repository includes:
- Terraform for VPC, subnet, SG, IAM role, and EC2 provisioning
- Ansible for secret retrieval using the amazon.aws collection
- Networking documentation and architecture diagrams
- Requirements and cost optimization documentation

---

## Project Objectives

1. Store a JSON secret in AWS Secrets Manager
2. Provision infrastructure using Terraform (VPC, subnet, IGW, EC2, IAM role)
3. Retrieve the secret using an Ansible playbook
4. Enforce IAM least-privilege by scoping GetSecretValue to a single secret ARN
5. Demonstrate end-to-end automation using local tooling (WSL or Linux control node)

---

## Repository Structure
├── README.md
├── networking.md
├── requirements.md
├── cost_optimization.md
├── diagrams/
│ └── aws-secrets-ansible-architecture-fixed.png
├── ansible/
│ ├── secrets_manager_retrieve.yml
│ └── inventory
└── terraform/
├── main.tf
├── outputs.tf
├── provider.tf
├── variables.tf


---

## Architecture Overview

The Terraform configuration creates a simple, cost-efficient AWS environment.  
The Ansible control node (local workstation or WSL) communicates directly with AWS Secrets Manager using the amazon.aws collection.

Architecture diagram (PNG):  
`diagrams/aws-secrets-ansible-architecture-fixed.png`

---

## Prerequisites

- Ansible 2.13 or later
- Terraform 1.x or later
- AWS CLI configured with valid credentials
- Install the Ansible AWS collection:

```bash
Deploy AWS Infrastructure Using Terraform
ansible-galaxy collection install amazon.aws

cd terraform
terraform init
terraform apply

Terraform creates:
VPC (10.0.0.0/16)
Public subnet (10.0.0.0/20)
Internet Gateway + route table
Security group with SSH from admin CIDR
IAM role with permissions for GetSecretValue
EC2 instance with public IP and instance profile

Run the Ansible Playbook
cd ansible
ansible-playbook -i inventory secrets_manager_retrieve.yml

The playbook retrieves the secret from AWS Secrets Manager using:
The amazon.aws.aws_secret module
IAM credentials from your AWS CLI
Optional EC2 role (if configured to retrieve from the instance)

Secret Structure Example
{
  "db_password": "P@ssw0rd123",
  "api_token": "example-token-value"
}

Teardown
cd terraform
terraform destroy
