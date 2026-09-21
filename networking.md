# Networking – AWS Secrets Manager + Ansible

## Purpose

The networking architecture supports the project's secrets-management and identity-based access design.

The implemented environment uses a public subnet and a publicly addressed EC2 instance to provide a straightforward administrative path for the demonstration. This design also introduces network exposure that must be explicitly considered from a security architecture perspective.

The objective is to demonstrate not only how connectivity works, but also how administrative access, workload identity, and network exposure affect the overall security boundary.

---

## Implemented Network Architecture

Terraform provisions:

- A dedicated VPC using `10.0.0.0/16`
- A public subnet using `10.0.0.0/20`
- An Internet Gateway
- A route table with a default route to the Internet Gateway
- A security group
- A public IP address for the EC2 instance

The security group permits inbound SSH only from the explicitly supplied `admin_cidr`.

The configuration does not default to unrestricted SSH access from the internet.

---

## Administrative Access Boundary

The EC2 instance is publicly reachable, which creates an administrative trust boundary between the internet-facing network path and the workload.

Administrative access is restricted to an explicitly approved source CIDR rather than allowing SSH from any internet address.

This demonstrates an important security principle:

> **Public network reachability and administrative authorization are separate architecture decisions.**

A workload may require network connectivity without requiring administrative access from every network location.

---

## Security Tradeoff

The public-subnet design provides a simple way to demonstrate connectivity and administrative access.

The tradeoff is increased exposure of the workload's network interface.

Restricting SSH to an approved administrative CIDR reduces that exposure, but it does not eliminate the risks associated with a publicly reachable management interface.

This is an intentional implementation tradeoff rather than an assumption that public administrative access represents the preferred production architecture.

---

## Relationship to Secrets Management

Network controls and secrets-management controls address different risks.

The network controls where administrative connections may originate.

Identity controls determine which AWS identity is authorized to retrieve the secret.

Secrets Manager provides centralized storage for the secret.

These controls operate together but are not interchangeable.

Restricting SSH does not replace least-privilege authorization for secret retrieval, and least-privilege authorization does not eliminate the need to protect administrative access paths.

---

## Trust Boundaries

The implemented architecture contains several relevant trust boundaries:

- Administrator to public EC2 management interface
- EC2 workload to AWS services
- Workload identity to Secrets Manager
- Local Ansible control node to AWS
- Internet-facing network path to the project VPC

Each boundary requires a different type of control.

Network filtering protects the administrative path, while identity-based authorization controls access to the secret.

---

## Production Architecture Considerations

Before approving this pattern for production, an architecture review should determine whether the workload actually requires:

- A public IP address
- Direct inbound SSH
- Internet-routable administrative access

Where those requirements do not exist, the architecture should evaluate private workload placement and managed administrative access that avoids exposing SSH directly to the internet.

Additional production considerations include:

- Private connectivity to required AWS services
- Network segmentation
- Restrictive outbound access
- Centralized administrative access
- Security monitoring
- Administrative access logging
- Separation of management and workload traffic

The appropriate controls depend on workload criticality, threat model, operational requirements, and organizational security standards.

---

## Architecture Decision

For the implemented project:

**Public subnet + public EC2 address + restricted administrative CIDR**

provides a straightforward environment for demonstrating the security pattern while limiting administrative access to an explicitly approved source.

For a production implementation:

**Private workload placement + controlled management access**

should be evaluated before approving direct public administrative connectivity.

The architectural principle is:

> **Connectivity should be granted because the workload requires it, not simply because it is the easiest path to implementation.**
