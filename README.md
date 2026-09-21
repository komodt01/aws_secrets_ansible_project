# AWS Secrets Management + Identity Security Architecture

## Overview

This project demonstrates a security architecture for retrieving secrets through identity-based authorization rather than embedding credentials in application code, automation scripts, or infrastructure configuration.

Terraform provisions the supporting AWS infrastructure and workload identity. Ansible demonstrates authorized retrieval of a secret from AWS Secrets Manager.

The central security principle is:

> **Keep secret material out of code and infrastructure configuration, authorize retrieval through identity, minimize access, and protect the secret throughout its lifecycle.**

The project focuses on the architecture surrounding a secret—not simply where the secret is stored.

---

## Security Problem

Applications and automation frequently require credentials, API keys, tokens, or other sensitive values.

Embedding those values directly in:

- Source code
- Terraform configuration
- Automation scripts
- Configuration files
- Deployment pipelines

creates additional exposure paths and makes credential lifecycle management more difficult.

Moving a credential into a secrets-management service addresses only part of the problem.

A secure architecture must also determine:

- Which identity may retrieve the secret
- Which secret that identity may access
- How administrative access is controlled
- Whether the secret can leak during retrieval
- How access is audited
- How permissions are removed when no longer required
- How secret rotation and compromise would be handled

---

## Architecture

The project implements several security layers.

### Secret Storage

AWS Secrets Manager provides centralized storage for the project secret.

Terraform creates the secret resource but does not contain or provision the secret value.

The value is populated separately through an authorized secret-entry process.

This keeps secret material out of the repository and avoids intentionally storing the secret value in Terraform state.

### Workload Identity

The EC2 instance receives an IAM role through an instance profile.

The role permits:

`secretsmanager:GetSecretValue`

only for the secret created by this project.

The workload therefore receives an AWS identity rather than requiring embedded AWS credentials.

### Ansible Retrieval

Ansible demonstrates retrieval of the secret through the AWS identity available to the Ansible control node.

The playbook is designed to confirm successful retrieval without displaying the secret value in normal automation output.

The local Ansible identity and the EC2 workload identity are separate trust contexts in the current implementation.

### Administrative Network Access

The project deploys the EC2 instance in a public subnet for a straightforward demonstration environment.

Inbound SSH is restricted to an explicitly supplied administrative CIDR rather than allowing unrestricted internet access.

A production architecture should evaluate private workload placement and managed administrative access before approving a publicly reachable management interface.

---

## Implemented Controls

### Preventive Controls

- Secret value kept out of Terraform configuration
- Secret value kept out of source control
- IAM permission scoped to the project secret
- Workload identity provided through an EC2 role
- Administrative SSH restricted to an approved CIDR
- Secret value suppressed from normal Ansible output

### Governance and Architecture Controls

- Explicit separation between administrative and workload identities
- Documented network exposure and production tradeoffs
- Defined trust boundaries
- Production security requirements separated from demonstrated functionality
- Cost decisions evaluated against security boundaries

### Production Controls Identified but Not Implemented

A production implementation should additionally evaluate:

- Secret rotation
- Centralized security monitoring
- Detection of unusual secret access
- Access reviews
- Private workload placement
- Managed administrative access
- Private connectivity to cloud services
- Customer-managed encryption keys when required
- Multi-account architecture
- Incident response for suspected secret compromise

These are documented architecture considerations rather than capabilities claimed as implemented by this repository.

---

## Trust Boundaries

The project highlights several distinct trust boundaries:

**Administrator → AWS**

The identity provisioning infrastructure has elevated permissions and must be governed separately from application access.

**Ansible Control Node → AWS**

The local Ansible process uses the AWS identity available to the control node.

**EC2 Workload → AWS Secrets Manager**

The EC2 instance receives a workload identity with permission limited to the project secret.

**Administrator → EC2**

Administrative connectivity crosses a public network path and is restricted through the approved source CIDR.

**Secret Retrieval → Secret Consumption**

Once retrieved, a secret temporarily exists in the consuming process. Secure storage therefore does not eliminate the need to protect the secret after retrieval.

---

## Repository Structure

```text
.
├── README.md
├── networking.md
├── requirements.md
├── cost_optimization.md
├── diagrams/
│   └── aws-secrets-ansible-architecture-fixed.png
├── ansible/
│   ├── inventory
│   └── secrets_manager_retrieve.yml
└── terraform/
    ├── main.tf
    ├── outputs.tf
    └── variables.tf
```

---

## Terraform Implementation

Terraform provisions:

- VPC
- Public subnet
- Internet Gateway
- Route table
- Security group
- EC2 instance
- IAM role
- IAM policy
- IAM instance profile
- Secrets Manager secret

The IAM policy grants only the secret-retrieval permission required by the project and scopes that permission to the project secret.

The secret value itself is intentionally not defined in Terraform.

---

## Ansible Implementation

The Ansible playbook retrieves the project secret from AWS Secrets Manager using the AWS identity available to the control node.

The secret value should not be printed to normal automation output.

This distinction matters because:

> **A secret can be securely stored and still be insecurely handled after retrieval.**

---

## Deployment

### Prerequisites

- Terraform
- Ansible
- AWS CLI
- `amazon.aws` Ansible collection
- AWS credentials with the permissions required to provision the project resources
- An approved administrative CIDR for SSH access

Install the Ansible AWS collection:

```bash
ansible-galaxy collection install amazon.aws
```

### Provision Infrastructure

```bash
cd terraform
terraform init
terraform plan -var="admin_cidr=<approved-cidr>"
terraform apply -var="admin_cidr=<approved-cidr>"
```

Terraform creates the secret container but does not populate its value.

Populate the secret separately through an authorized secret-management process before testing retrieval.

### Run the Ansible Retrieval

```bash
cd ansible
ansible-playbook -i inventory secrets_manager_retrieve.yml
```

The playbook should confirm that retrieval succeeded without exposing the secret value.

---

## Security Failure Scenarios

The architecture should account for scenarios such as:

- IAM permissions becoming broader than intended
- Administrative network access becoming overly permissive
- Secret values appearing in logs or debug output
- Compromise of the Ansible control node
- Compromise of the workload identity
- Unauthorized secret retrieval
- Failure of security audit logging
- Failure to rotate a compromised secret
- Access remaining after a workload no longer requires it

The current project demonstrates selected preventive controls while documenting additional monitoring, lifecycle, and governance requirements for production.

---

## Cost and Security

Cost optimization is not treated independently from security.

Consolidating identities, sharing secrets, reducing logging, or eliminating security controls may reduce cost or complexity while simultaneously increasing risk.

See:

`cost_optimization.md`

for the project's cost and security tradeoff analysis.

---

## Supporting Architecture Documentation

### Requirements

`requirements.md`

Defines the security objective, functional requirements, trust boundaries, control-failure considerations, and production requirements.

### Networking

`networking.md`

Explains the implemented network architecture, administrative trust boundary, security tradeoffs, and production alternatives.

### Cost and Security Tradeoffs

`cost_optimization.md`

Examines cost decisions in the context of identity isolation, secret lifecycle, logging, network exposure, and security governance.

---

## Teardown

When the project resources are no longer required:

```bash
cd terraform
terraform destroy -var="admin_cidr=<approved-cidr>"
```

Resources or secret values created outside Terraform must be handled separately.

---

## Architecture Takeaway

Secrets management is not simply a storage problem.

A complete security architecture must consider:

**Secret storage → Identity → Authorization → Retrieval → Consumption → Audit → Rotation → Revocation**

The security objective is not merely to hide a password.

It is to control the entire path through which sensitive credentials are stored, accessed, used, monitored, and eventually replaced or revoked.
