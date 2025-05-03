# Why This Project Matters (Business Value)

In regulated industries like **healthcare, finance, and insurance**, storing credentials in plaintext or embedding them in configuration files violates security and compliance mandates such as **PCI-DSS, HIPAA, and NIST 800-53**.

This project demonstrates a **real-world scenario** where a cloud-hosted application (e.g., internal finance dashboard or patient portal) needs access to credentials — without compromising security.

By combining **Terraform for automated infrastructure** and **Ansible for secure configuration**, this solution:
- Prevents secret sprawl across environments
- Centralizes credential access logging in **CloudTrail**
- Maintains **auditability and least privilege**
- Prepares your environment for **zero-trust adoption** and future compliance assessments