# Business Case: Vault + AWS Secrets Manager

An enterprise transitioning to multi-cloud needs a secure, auditable solution for managing dynamic secrets and minimizing hardcoded credentials. The team uses Ansible for infrastructure automation and requires secure, automated retrieval of secrets without exposing them in playbooks or logs.

This project integrates HashiCorp Vault and AWS Secrets Manager to deliver centrally managed secrets, dynamic credential rotation, and detailed audit logging. It ensures that secrets access is tied to IAM roles and tracked for compliance, supporting NIST 800-53 AC-6, AU-2, and SC-12 controls.
