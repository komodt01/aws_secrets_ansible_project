# Cost Optimization – AWS Secrets Manager + Ansible Project

This document summarizes the main cost drivers and optimization strategies for the **AWS Secrets Manager + Ansible** lab.

---

## 1. Primary Cost Components

1. **AWS Secrets Manager**
   - Charged per secret per month.
   - Additional cost for `GetSecretValue` API calls (very low for this small lab).
2. **EC2 Instance**
   - Single `t3.micro` instance used as a demo host (or not used at all if Ansible runs only from localhost).
3. **Networking**
   - Minimal internet data transfer for SSH, YUM/apt updates, and API calls.
4. **IAM, VPC, Security Groups**
   - No direct cost, but they influence how other services are used.

---

## 2. Instance Rightsizing & Runtime

- Use **t3.micro** for the EC2 demo instance; it is sufficient for:
  - Running a simple app or test scripts.
  - Demonstrating Secrets Manager integration.
- Stop or destroy the instance when not in use:
  - For quick experiments, consider **Terraform `destroy`** at the end of each run.
  - For multi-day use, at least **stop** the instance outside of active testing.

---

## 3. Secrets Manager Optimization

- Use a **single secret** (e.g., `ansible_secret`) with a small JSON payload rather than multiple separate secrets when appropriate for the demo.
- Avoid unnecessary `GetSecretValue` calls in loops; retrieve once per playbook run and reuse the result.
- Delete the secret when the lab is complete, or move it to a dedicated “test” environment and clearly tag it.

---

## 4. Logging & Data Retention

- CloudTrail incurs storage and potential analysis costs, but is essential for auditing API calls:
  - Use standard retention periods for the account (e.g., 30–90 days).
- If CloudWatch Logs are used:
  - Set a **retention** period (e.g., 14–30 days) for any log groups created for this project.
  - Avoid verbose debug logging in production; this demo can use debug logs temporarily.

---

## 5. Tagging & Budget Controls

- Apply consistent tags to all resources:
  - `Project = "AWS Secrets Manager + Ansible"`
  - `Environment = "Demo"`
  - `Owner = "<YourName>"`
- Create an **AWS Budget** scoped to:
  - The entire account (simple) or filtered by project tags (preferred).
  - Set a low monthly threshold (e.g., **$5–$15**) for this project.
- Configure alerts when:
  - Actual cost > 80% of budget.
  - Forecasted cost is expected to exceed the budget.

---

## 6. Teardown Strategy

- Provide a documented **teardown sequence**:
  1. Delete the Ansible-created resources (if any).
  2. Use `terraform destroy` to remove:
     - EC2 instance
     - Security group
     - Subnet, route table, IGW, and VPC
     - IAM role and instance profile
  3. Delete the Secrets Manager secret if no longer needed.
- This reduces ongoing charges to nearly zero between labs.

---

## 7. Future Optimization Opportunities

- Integrate this lab into a **shared development VPC** instead of provisioning a dedicated one, if used frequently.
- If extended to multiple workloads, consider:
  - Reusing the same secret and IAM role.
  - Rotating secrets automatically using Lambda while keeping overall secret count low.
