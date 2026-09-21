# Networking – AWS Secrets Manager + Ansible

## Purpose

The networking in this project supports a simplified lab environment for demonstrating secrets management, identity-based access, and administrative connectivity.

The implemented environment uses a public subnet and a publicly addressed EC2 instance. This design keeps the lab simple, but it also creates an administrative exposure that would require additional consideration in a production architecture.

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

It does not default to unrestricted SSH access from the internet.

---

## Administrative Access Boundary

The public EC2 instance creates an administrative trust boundary between the internet-facing network path and the workload.

For the lab, this risk is reduced by restricting SSH access to an approved administrative CIDR.

This demonstrates an important security principle:

> Public reachability and administrative authorization are separate decisions.

A resource may require network connectivity without requiring administrative access from every network location.

---

## Security Tradeoff

Using a public subnet simplifies the demonstration and avoids additional infrastructure.

The tradeoff is increased exposure of the workload's network interface to an internet-routable environment.

The lab therefore accepts a simplified network architecture while applying a restrictive inbound access rule.

This is a lab design decision rather than a recommendation for production administrative access.

---

## Relationship to Secrets Management

Network controls and secrets-management controls address different risks.

The network restricts where administrative connections may originate.

Identity controls determine which AWS identity may retrieve the secret.

Secrets Manager protects centralized secret storage.

These controls complement one another but should not be treated as interchangeable.

Restricting SSH does not replace least-privilege secret access, and least-privilege secret access does not eliminate the need to protect administrative paths.

---

## Production Architecture Considerations

A production design should evaluate whether the workload requires:

- A public IP address
- Direct inbound SSH
- Internet-routable administrative access

Where those requirements do not exist, a stronger design could place the workload in a private subnet and use a managed administrative access mechanism rather than exposing SSH directly.

Production architecture should also evaluate:

- Private connectivity to required AWS services
- Centralized administrative access
- Network segmentation
- Egress restrictions
- Security monitoring
- Access logging
- Separation between management and workload traffic

The appropriate design depends on operational requirements, threat models, and organizational security standards.

---

## Architecture Decision

For this lab:

**Public subnet + restricted administrative CIDR**

was selected for simplicity and demonstrability.

For production:

**Private workload placement + controlled management access**

would generally be evaluated before allowing direct public administrative connectivity.

The important architectural principle is that convenience, cost, and security exposure should be treated as an explicit tradeoff rather than assuming that a working network configuration is automatically an appropriate production security design.
