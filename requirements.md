# Requirements – AWS Secrets Manager + Ansible Project

## 1. Purpose

This project demonstrates how to securely retrieve application secrets from **AWS Secrets Manager** using **Ansible**, with AWS infrastructure provisioned by **Terraform**.

The goals are to:
- Store a secret in AWS Secrets Manager.
- Provision network and compute resources for a demo environment.
- Retrieve the secret using an Ansible playbook and show it can be consumed securely.

---

## 2. Functional Requirements

### 2.1 Secret Management

- R1.1 – Create an AWS Secrets Manager secret (e.g., `ansible_secret`) containing a key/value payload.
- R1.2 – Allow authorized workloads (Ansible or EC2 instance) to call `GetSecretValue` on this secret.
- R1.3 – Demonstrate successful retrieval of the secret in an Ansible playbook.

### 2.2 Infrastructure Provisioning (Terraform)

- R2.1 – Provision a dedicated **VPC** (e.g., `10.0.0.0/16`).
- R2.2 – Create a **public subnet** (e.g., `10.0.0.0/20`) and associate it with:
  - Internet Gateway
  - Route table with default route to the internet.
- R2.3 – Create a **security group** that:
  - Allows SSH (22) from an admin CIDR.
  - Optionally allows HTTP/HTTPS if needed for testing.
- R2.4 – Launch an **EC2 instance** (e.g., `t3.micro`) tagged as:
  - `Project = "AWS Secrets Manager + Ansible"`
  - `Environment = "Demo"`
- R2.5 – Attach an **IAM instance profile/role** granting the instance access to `GetSecretValue` for the secret.

### 2.3 Configuration Management (Ansible)

- R3.1 – Define an inventory that targets `localhost` (or the Ansible control node).
- R3.2 – Implement an Ansible playbook (`secrets_manager_retrieve.yml`) that:
  - Uses the `amazon.aws.aws_secret` module to retrieve `ansible_secret` from Secrets Manager.
  - Prints or logs the retrieved value to verify access.
- R3.3 – (Optional) Extend the playbook to configure the EC2 instance using SSH:
  - Install packages.
  - Write the secret value into a configuration file or environment variable.

---

## 3. Non-Functional Requirements

### 3.1 Security

- N1.1 – Use IAM **least privilege** for the Secrets Manager access policy:
  - Allow `secretsmanager:GetSecretValue` only on the specific secret ARN.
- N1.2 – Ensure the secret is encrypted with the default AWS-managed KMS key or a customer-managed key.
- N1.3 – Do not hard-code secret values in Terraform, Ansible, or source code; only references/ARNs.
- N1.4 – Limit SSH access to a known admin CIDR.

### 3.2 Observability

- N2.1 – Enable CloudTrail in the account (or rely on existing) so all Secrets Manager and IAM calls are logged.
- N2.2 – Optionally send EC2 system logs to CloudWatch Logs.

### 3.3 Maintainability

- N3.1 – Use Terraform for all infrastructure provisioning and destruction.
- N3.2 – Keep playbooks idempotent where possible.
- N3.3 – Document all prerequisites (AWS CLI, Terraform, Ansible, Python libraries) in `README.md`.

---

## 4. Tooling & Environment Requirements

- T1 – Terraform 1.x or later.
- T2 – Ansible 2.13+ with the `amazon.aws` collection installed.
- T3 – AWS CLI configured with credentials that can:
  - Create VPC, subnet, IGW, route tables.
  - Create security groups, EC2 instances, IAM roles, and instance profiles.
  - Create and manage a Secrets Manager secret.
- T4 – Ansible control node (local machine, WSL, or EC2) with network access to AWS APIs.

---

## 5. Assumptions

- A1 – This is a **demo / lab** project, not production.
- A2 – The same AWS account is used for Terraform, Ansible, and Secrets Manager.
- A3 – The user has permissions to create and delete all resources.

---

## 6. Out of Scope

- O1 – High availability or auto-scaling of the EC2 instance.
- O2 – Advanced secret rotation workflows.
- O3 – CI/CD integration for playbook or Terraform execution.
- O4 – Multi-account or cross-region secret replication.
