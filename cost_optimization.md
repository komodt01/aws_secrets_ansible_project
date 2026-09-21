# Cost and Security Tradeoffs – AWS Secrets Manager + Ansible

## Purpose

Cloud security architecture must consider cost and operational efficiency without weakening required security boundaries.

This project uses a focused implementation to demonstrate secrets management, identity-based authorization, and controlled administrative access. Several design decisions illustrate how cost, operational simplicity, and security requirements affect one another.

The objective is not simply to minimize spending. It is to determine where optimization is reasonable and where reducing cost or complexity could introduce unacceptable security risk.

---

## Primary Cost Considerations

The primary resources that may generate cost in this project include:

- AWS Secrets Manager
- EC2 compute
- Network usage
- Logging and monitoring when those capabilities are enabled

IAM, security groups, and the core VPC configuration primarily affect security architecture and access boundaries rather than serving as significant direct cost drivers.

---

## Compute Lifecycle

The EC2 instance supports the project implementation and workload-identity design.

Keeping temporary compute resources running when they are not required provides little architectural value while continuing to consume resources.

Reasonable lifecycle controls include:

- Destroying temporary environments after validation
- Stopping compute resources between testing periods
- Recreating infrastructure through Terraform when required

Infrastructure as Code supports this model by making environments reproducible rather than requiring resources to remain deployed indefinitely.

---

## Secret Lifecycle

Secrets should exist only as long as they serve a legitimate business or technical purpose.

The project therefore emphasizes:

- Maintaining only required secrets
- Removing obsolete secrets
- Retrieving secrets only when required
- Avoiding unnecessary duplication of secret material
- Keeping secret values outside source code and infrastructure configuration

Cost optimization should not become a reason to combine unrelated credentials into a single secret.

Different workloads may require separate secrets because they have different owners, permissions, rotation requirements, consumers, and risk profiles.

---

## Identity Boundaries vs. Operational Simplicity

Reusing one identity across multiple workloads may reduce administrative effort, but it can also increase the impact of a compromised workload.

A production architecture should preserve appropriate identity boundaries even when doing so introduces additional configuration or operational overhead.

The architecture question is not:

> "How few roles can we create?"

It is:

> **"Which workloads should share the same authorization boundary?"**

That decision should be based on access requirements, ownership, and risk rather than convenience alone.

---

## Logging and Retention

Security logging introduces storage, monitoring, and operational costs.

However, reducing required audit visibility purely to lower cost can create greater security, compliance, and incident-response risk.

Production retention requirements should consider:

- Security investigation needs
- Regulatory obligations
- Organizational policy
- Incident-response requirements
- Data volume
- Cost

Logging and retention are therefore governance decisions as well as technical and financial decisions.

---

## Network Architecture Tradeoff

The implemented environment uses a public subnet and restricted administrative access to keep the demonstration architecture straightforward.

That simplicity creates a security tradeoff.

A production environment may justify additional controls even when they introduce greater cost or operational complexity, including:

- Private workload placement
- Managed administrative access
- Private connectivity to cloud services
- Additional network monitoring
- More restrictive egress controls

These controls should be evaluated against the sensitivity of the workload, threat model, business requirements, and organizational security standards.

---

## Security Controls Should Not Be Removed for Cost Alone

Some architecture decisions can reduce cost while also changing the security boundary.

Examples include:

- Consolidating identities
- Sharing secrets across workloads
- Reducing logging
- Shortening audit retention
- Removing network controls
- Eliminating monitoring capabilities

These decisions should not be treated as purely financial optimizations.

Any change that materially alters security exposure should be evaluated as a risk decision.

---

## Resource Lifecycle and Teardown

Because the project infrastructure can be recreated through Terraform, temporary resources do not need to remain deployed when they are no longer required.

Before teardown, the administrator should verify that:

- Required data does not depend on the environment
- Secrets are no longer required
- Resources created outside Terraform are handled separately
- Required audit or security evidence is retained according to policy

This allows unnecessary resources to be removed without treating security controls as disposable cost items.

---

## Production Decision Criteria

When moving this architecture toward production, cost decisions should be evaluated alongside:

- Data and credential sensitivity
- Workload criticality
- Required availability
- Identity isolation
- Network exposure
- Audit requirements
- Secret rotation requirements
- Operational support
- Incident-response requirements
- Compliance obligations

The lowest-cost architecture is not automatically the appropriate architecture.

---

## Architecture Principle

Cost optimization should operate within established security boundaries.

Reducing infrastructure, consolidating identities, sharing secrets, or reducing audit capabilities may lower cost, but each decision can also change organizational risk.

The architectural objective is:

> **Optimize cost within the required security boundaries rather than weakening the security boundaries to minimize cost.**
