# Requirements – AWS Secrets Manager + Ansible

## 1. Purpose

This project demonstrates a secure pattern for retrieving application secrets from AWS Secrets Manager using identity-based authorization rather than embedding credentials in application code, automation scripts, or infrastructure configuration.

Terraform provisions the supporting AWS resources, while Ansible demonstrates authorized secret retrieval.

This is a lab implementation intended to explore the security architecture pattern rather than represent a production deployment.

---

## 2. Security Objective

The primary security objective is:

> Applications and automation should retrieve secrets through an authorized identity without storing or exposing the secret unnecessarily.

The design should address:

- Where secret material is stored
- Which identity can retrieve it
- What permissions that identity receives
- How administrative access is restricted
- How secret values are protected during retrieval
- How access can be audited
- What additional controls would be required for production

---

## 3. Functional Requirements

### 3.1 Secret Management

- R1.1 – Create a dedicated AWS Secrets Manager secret.
- R1.2 – Keep the secret value outside Terraform configuration and source control.
- R1.3 – Allow an authorized identity to retrieve the secret.
- R1.4 – Demonstrate successful secret retrieval through Ansible.
- R1.5 – Do not display the retrieved secret value during normal automation output.

### 3.2 Infrastructure Provisioning

Terraform should provision the supporting demonstration environment:

- Dedicated VPC
- Public subnet
- Internet Gateway
- Route table
- Security group
- EC2 instance
- IAM role
- IAM instance profile
- Secrets Manager secret

The EC2 instance is included to demonstrate workload identity and role-based access to the secret.

### 3.3 Identity and Access

The workload identity should:

- Use an IAM role rather than embedded AWS credentials.
- Receive only the Secrets Manager action required by the demonstration.
- Be authorized only for the project secret.
- Avoid broad access to unrelated secrets.

The implemented permission is:

`secretsmanager:GetSecretValue`

scoped to the ARN of the secret created by the project.

### 3.4 Administrative Access

SSH access to the demonstration instance must be restricted to an explicitly supplied administrative CIDR.

The configuration must not default to unrestricted inbound SSH from the internet.

### 3.5 Ansible Secret Retrieval

The Ansible playbook should:

- Retrieve the project secret from AWS Secrets Manager.
- Use an authorized AWS identity.
- Prevent the retrieved value from being exposed through normal Ansible task output.
- Confirm successful retrieval without printing the secret itself.

---

## 4. Security Requirements

### 4.1 Secret Handling

Secret values must not be committed to source control.

Terraform should create the secret resource but should not manage the secret value in this repository.

The secret value should be populated separately through an authorized secret-entry process.

This prevents secret material from being embedded in Terraform configuration and avoids intentionally placing the value in Terraform state.

### 4.2 Least Privilege

Secret retrieval permissions must be limited to:

- The required action
- The intended secret
- The identity that requires access

Access to all secrets in the account is not required for this demonstration.

### 4.3 Secret Exposure

Retrieving a secret securely does not guarantee that the secret remains protected after retrieval.

Automation must avoid exposing secret values through:

- Console output
- Automation logs
- Debug output
- Source control
- Infrastructure configuration
- Unprotected files

### 4.4 Network Access

Administrative network access must be explicitly restricted.

The lab uses a public subnet for simplicity, but public reachability does not justify unrestricted administrative access.

### 4.5 Auditability

Secret access should be auditable through AWS account logging.

A production implementation should ensure that secret retrieval and relevant identity activity are captured by the organization's centralized security logging and monitoring capabilities.

---

## 5. Trust Boundaries

The architecture includes several important trust boundaries.

### Administrator to AWS

The administrator or automation identity provisioning infrastructure has elevated permissions and must be protected separately from the workload identity.

### Workload to Secrets Manager

The workload identity is authorized to retrieve only the secret required for its function.

### Ansible Control Node to AWS

When the playbook runs from a local control node, secret retrieval occurs using the AWS identity available to that control node.

That identity is distinct from the EC2 instance role unless the playbook is executed from the instance itself.

### Secret Retrieval to Secret Consumption

Once retrieved, the secret temporarily exists within the consuming process.

Protecting the secret after retrieval is therefore part of the security boundary.

---

## 6. Control Failure Considerations

A production architecture should consider what happens if:

- The workload role receives excessive permissions.
- Administrative network access becomes overly broad.
- A secret value is exposed through logs or debug output.
- Credentials on the Ansible control node are compromised.
- The secret is retrieved by an unexpected identity.
- Audit logging is unavailable.
- The secret is not rotated when required.
- Access remains after the workload no longer requires it.

These conditions require monitoring, ownership, and defined response procedures beyond the scope of this lab.

---

## 7. Production Considerations

This lab intentionally uses a simplified environment.

A production design should evaluate:

- Private workload placement
- Alternatives to direct SSH administration
- Centralized identity and access governance
- Customer-managed encryption keys when required
- Secret rotation
- Secret lifecycle management
- Access reviews
- Centralized audit logging
- Detection of unusual secret access
- Network controls for access to AWS services
- Multi-account architecture
- Separation of administrative and workload identities
- Incident response for suspected secret compromise

These are architecture decisions based on business requirements, threat models, compliance obligations, and operational constraints.

---

## 8. Tooling

The demonstration uses:

- Terraform for infrastructure provisioning
- AWS Secrets Manager for managed secret storage
- AWS IAM for identity-based authorization
- Amazon EC2 for the demonstration workload
- Ansible for secret retrieval
- AWS account credentials for local administrative or control-node operations

---

## 9. Assumptions

- This repository represents a lab environment.
- The AWS account used for the lab permits creation and deletion of the required resources.
- An authorized administrator populates the secret value separately after infrastructure deployment.
- AWS account-level audit logging is available or would be required in a production environment.
- The EC2 instance and local Ansible control node represent different identity contexts.

---

## 10. Out of Scope

The current implementation does not demonstrate:

- Automated secret rotation
- Multi-account secret sharing
- Cross-region replication
- Production high availability
- CI/CD integration
- Centralized security monitoring
- Automated access reviews
- Production incident-response workflows

These capabilities would require additional architecture and governance beyond the scope of the lab.

---

## Architecture Requirement

The central requirement of this project is not simply:

> "Store a password in a secrets service."

It is:

> **Keep secret material out of application and infrastructure code, authorize retrieval through identity, minimize access, and protect the secret throughout its lifecycle.**
