# Technical Case Study – Secrets Management and Identity Security Architecture

## Architecture Problem

Applications, automation, and infrastructure processes frequently require credentials, tokens, API keys, or other sensitive values.

A common security failure is to embed those values directly in source code, configuration files, infrastructure-as-code, or automation scripts.

Moving a credential into a managed secrets service reduces that exposure, but storage alone does not create a complete secrets-management architecture.

The broader architecture must address:

- Secret storage
- Identity
- Authorization
- Retrieval
- Consumption
- Administrative access
- Auditability
- Rotation
- Revocation
- Exception handling
- Control failure

The security objective for this project is:

> **Keep secret material out of application and infrastructure code, authorize retrieval through identity, minimize access, and protect the secret throughout its lifecycle.**

---

## Assets Being Protected

The primary asset is the secret value.

The actual business impact, however, depends on what that credential can access.

A compromised secret could provide access to:

- Application services
- Databases
- APIs
- Administrative interfaces
- Sensitive business data
- Other protected resources

Secrets management therefore protects not only the credential itself but also the downstream systems and data authorized by that credential.

---

## Architecture Decision

AWS Secrets Manager is used as the centralized location for the project secret.

Terraform creates the secret resource but does not define the secret value.

The secret value is populated separately through an authorized process.

This decision prevents the project from intentionally placing secret material in:

- Terraform configuration
- Source control
- Terraform-managed secret resources
- Terraform state

The architecture separates secret provisioning from infrastructure provisioning.

---

## Identity and Authorization

### EC2 Workload Identity

The EC2 instance receives an IAM role through an instance profile.

The associated policy permits:

`secretsmanager:GetSecretValue`

only for the secret created by this project.

This demonstrates an important security principle:

> **A workload should receive an identity with access to the resources it requires rather than receive reusable cloud credentials embedded in its configuration.**

The permission is scoped to the project secret rather than using unrestricted secret access.

### Ansible Control-Node Identity

The Ansible implementation runs against `localhost`.

The playbook therefore uses the AWS identity available to the Ansible control node.

This is a separate identity context from the EC2 instance role.

That distinction is important because the identity performing automation may have different privileges, ownership, and compromise scenarios from the workload consuming the secret.

The architecture does not treat these identities as interchangeable.

---

## Secret Retrieval and Consumption

The Ansible playbook retrieves the secret from AWS Secrets Manager.

The retrieval task uses:

`no_log: true`

to suppress sensitive task output.

The playbook confirms successful retrieval without printing the secret value.

This addresses a common secrets-management failure:

> **A secret may be securely stored but still become exposed during retrieval or consumption.**

Secret handling therefore remains part of the security boundary after the secret leaves the secrets-management service.

---

## Administrative Network Boundary

The demonstration environment places the EC2 instance in a public subnet with a public IP address.

Administrative SSH access is restricted to the explicitly supplied `admin_cidr`.

The architecture therefore separates two decisions:

1. Whether the workload is network reachable
2. Who is authorized to use the administrative interface

Restricting SSH reduces exposure but does not make public administrative access the preferred production architecture.

For production, private workload placement and managed administrative access should be evaluated before approving inbound SSH.

---

## Trust Boundaries

### Administrator → AWS

The administrator or provisioning process requires permissions to create infrastructure, identities, policies, and the secret resource.

This is a privileged administrative boundary and should be governed separately from workload access.

### Ansible Control Node → AWS

The Ansible process uses the AWS identity available to the control node.

Compromise of that environment could expose any permissions available to that identity.

### EC2 Workload → AWS Secrets Manager

The EC2 instance receives an AWS workload identity.

Its secret-read permission is scoped to the project secret.

### Administrator → EC2

Administrative connectivity crosses a public network path in the demonstration architecture.

The source network is restricted through `admin_cidr`.

### Secrets Manager → Consuming Process

After retrieval, plaintext secret material exists within the authorized consuming process.

The secrets service can protect storage and access but cannot prevent an already-authorized process from mishandling the value after retrieval.

### Terraform State

Terraform state is a security boundary because sensitive values managed through Terraform can become stored in state.

The project intentionally avoids provisioning the secret value through Terraform.

---

## Threat and Failure Scenarios

The architecture should account for several realistic failure conditions.

### Secret Embedded in Source

A credential committed to source control can persist in repository history even after the visible file is corrected.

**Control:** Secret material is not defined in the project source.

### Secret Stored in Terraform State

Provisioning a secret value through Terraform can place that value in state.

**Control:** Terraform creates the secret resource but not the secret value.

### Excessive Secret Permissions

A workload with unrestricted secret-read permissions could access credentials unrelated to its business function.

**Control:** `GetSecretValue` is scoped to the project secret.

### Secret Exposure Through Automation Output

Debugging or verbose automation can expose retrieved credentials.

**Control:** Sensitive retrieval output is suppressed and the secret value is not printed.

### Overly Broad Administrative Access

Unrestricted SSH would expose the management interface to unnecessary network sources.

**Control:** SSH is restricted to the supplied administrative CIDR.

### Compromised Control Node

If the Ansible control node is compromised, an attacker may inherit its AWS permissions.

**Control consideration:** Control-node identity should be independently scoped, monitored, and governed.

### Compromised Workload Identity

A compromised EC2 workload could use permissions assigned to its role.

**Control:** The role's secret permission is limited to the required secret.

### Stale Access

A workload or administrator may retain access after the business requirement disappears.

**Production requirement:** Periodic access review and lifecycle-driven revocation.

### Compromised Secret

A valid credential may become known to an unauthorized party.

**Production requirement:** Rotation and incident-response procedures must support rapid credential replacement.

---

## Preventive, Detective, and Corrective Controls

### Preventive

The project demonstrates preventive controls including:

- No secret value in source code
- No secret value provisioned through Terraform
- Resource-scoped secret retrieval permission
- Workload identity instead of embedded AWS credentials
- Restricted administrative SSH
- Suppression of secret output

### Detective

A production implementation should establish detective controls for:

- Secret-access activity
- Authorization changes
- Unexpected access patterns
- Changes to administrative network access
- Policy drift
- Failed or unusual retrieval attempts

The repository does not claim these monitoring capabilities as implemented.

### Corrective

Corrective capabilities should address:

- Credential rotation
- Permission revocation
- Compromised identity response
- Removal of stale access
- Restoration of approved policy
- Secret replacement after suspected exposure

These are production architecture requirements rather than implemented capabilities in this project.

---

## Control Failure and Assurance

A security control should not be considered effective solely because it was configured once.

Production assurance should answer questions such as:

- Can the authorized identity retrieve only the intended secret?
- Is an unauthorized identity denied?
- Can secret access be traced to an identity?
- Can policy drift be detected?
- Can administrative access become broader without detection?
- Does rotation work without breaking the consuming application?
- Can access be revoked quickly?
- Can security teams determine whether a credential was accessed during an incident?

This moves the architecture from control deployment to control assurance.

---

## Residual Risk

The architecture reduces several common secret-management risks but does not eliminate them.

Residual risks include:

- An authorized workload can retrieve plaintext secret material
- A compromised authorized process may misuse a valid credential
- The Ansible control node may have permissions beyond this project
- Public workload placement increases network exposure
- Rotation is not implemented
- Centralized detection is not implemented
- Access reviews are not implemented
- Secret misuse may occur after legitimate retrieval

These risks would require additional production controls based on workload sensitivity and business impact.

---

## Exception Governance

Production environments may require exceptions such as:

- Temporary administrative access
- Emergency secret retrieval
- Temporary expansion of permissions
- Delayed rotation because of application dependencies

An exception should identify:

- Business justification
- Scope
- Owner
- Approver
- Start date
- Expiration date
- Compensating controls
- Required monitoring
- Removal criteria

An exception should represent a governed deviation from the architecture rather than an undocumented permanent configuration.

---

## Production Architecture Considerations

Before approving this pattern for production, an Architecture Review Board should evaluate:

- Private versus public workload placement
- Managed administrative access instead of inbound SSH
- Secret rotation requirements
- Centralized security monitoring
- Detection of unusual secret access
- Access-review frequency
- Terraform state protection
- Separation of provisioning and runtime identities
- Multi-account boundaries
- Encryption-key ownership requirements
- Private service connectivity
- Incident response for secret compromise
- Application behavior when secret retrieval fails
- Exception ownership and expiration

The appropriate controls depend on the sensitivity and business criticality of the workload.

---

## Architecture Decision Summary

The project demonstrates several deliberate security decisions:

**Secret storage:** Centralize secret material rather than embed it in code.

**Infrastructure provisioning:** Create the secret resource without placing its value into Terraform-managed configuration or state.

**Authorization:** Scope secret retrieval to the required secret.

**Workload identity:** Use an assigned cloud identity instead of embedded cloud credentials.

**Automation:** Retrieve the secret without displaying it.

**Administrative access:** Restrict management access rather than expose SSH broadly.

**Identity boundaries:** Treat the Ansible control node and EC2 workload as separate security principals.

**Production governance:** Treat monitoring, rotation, access review, exceptions, and incident response as part of the architecture rather than optional operational details.

---

## Architecture Takeaway

The primary lesson from this project is that secrets management is not simply a vaulting decision.

A complete security architecture must govern the path:

**Secret Storage → Identity → Authorization → Retrieval → Consumption → Audit → Rotation → Revocation**

The security question is therefore not simply:

> "Where is the secret stored?"

It is:

> **"Which identity can retrieve the secret, under what conditions, how is that access verified, what happens when a control fails, and how is the credential governed throughout its lifecycle?"**

That is the distinction between storing a secret and designing a secrets-management security architecture.
