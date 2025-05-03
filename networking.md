# Networking Overview for AWS Secrets Manager + Ansible Project

## Purpose of Networking Components

This project deploys an EC2 instance in a **public subnet** to allow direct SSH access and enable Ansible automation. The networking setup is intentionally simple and cost-efficient while adhering to real-world security best practices.

---

## Key Components

### ✅ VPC (Virtual Private Cloud)
A logically isolated network environment for your AWS resources.

### ✅ Subnet
- **Type**: Public
- **Purpose**: Hosts the EC2 instance with direct internet access

### ✅ Internet Gateway (IGW)
- **Purpose**: Allows the EC2 instance to communicate with the internet
- **Why it matters**: Without an IGW, resources in your VPC cannot send or receive traffic from the internet.

### ✅ Route Table
- **Configured Route**: `0.0.0.0/0` → IGW
- **Associated With**: The public subnet
- **Why it matters**: Ensures outbound and inbound traffic can be routed through the Internet Gateway

### ✅ Public IP Assignment
- **EC2 Setting**: `associate_public_ip_address = true`
- **Why it matters**: Required for Ansible and SSH access from your local or admin machine

### ❌ NAT Gateway
- **Not required**
- Only needed when EC2 instances are in private subnets and must reach the internet without being reachable from it

---

## Visual Summary

```
[ Internet ] 
     |
[ Internet Gateway ]
     |
[ Route Table: 0.0.0.0/0 → IGW ]
     |
[ Public Subnet ]
     |
[ EC2 Instance (Public IP) ]
```

---

## Why This Design?

- ✅ Simple and cost-effective
- ✅ Enables remote Ansible configuration without a bastion
- ✅ Follows AWS security best practices for public-facing management