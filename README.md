# AWS Secrets Manager + Ansible Automation Project

## Project Overview
This project demonstrates how to securely retrieve secrets from AWS Secrets Manager using Ansible for configuration automation.

## Technologies Used
- **Terraform**: Provision infrastructure including IAM roles, policies, and Secrets Manager secret.
- **Ansible**: Automate configuration and secret retrieval via `boto3` and AWS credentials.
- **Python**: Secret retrieval logic used in Ansible playbook.
- **AWS Secrets Manager**: Centralized secrets storage.
- **IAM**: Fine-grained permissions to access secrets securely.

## Directory Structure
```
aws_secrets_ansible_project/
├── terraform/
│   └── main.tf, variables.tf, outputs.tf
├── ansible/
│   └── retrieve_secret.yml
│   └── inventory.ini
│   └── files/
│       └── secret_retriever.py
├── README.md
├── cleanup.sh
```

## How to Run
1. Navigate to the `terraform` directory and deploy with:
   ```bash
   terraform init && terraform apply
   ```

2. Navigate to the `ansible` directory and run the playbook:
   ```bash
   ansible-playbook -i inventory.ini retrieve_secret.yml
   ```

## Cleanup
To destroy all AWS infrastructure and prevent charges, run:
```bash
bash cleanup.sh
```
