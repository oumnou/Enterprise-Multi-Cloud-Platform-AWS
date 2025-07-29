# 🚀 Multi-Cloud Platform AWS Infrastructure

[![Terraform](https://img.shields.io/badge/Terraform-v1.5-blue?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Cloud-orange?logo=amazon-aws)](https://aws.amazon.com/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

---

## 🌐 Project Overview

This Terraform project deploys a **robust AWS infrastructure** designed for a multi-cloud cybersecurity platform supporting various user roles and operational needs. It features networking, compute resources, security hardening, logging, and access management tailored for enterprise-grade environments.

---

## 🏗 Architecture Diagram

*(You can create a diagram using tools like [Diagrams.net](https://app.diagrams.net/) or [Lucidchart](https://www.lucidchart.com/). Example components:)*

- VPC with public & private subnets across multiple Availability Zones (eu-west-3a, eu-west-3b)
- Internet Gateway for outbound traffic
- Public EC2 (bastion + admin dashboard)
- Private EC2 (backend apps)
- Security Groups restricting access
- IAM users/groups & policy mapping
- CloudTrail logging with centralized S3 bucket
- AWS Config for compliance monitoring

---

## 📋 Features & Components

### 1. **Networking**

| Resource         | Description                                | CIDR / Details           |
|------------------|--------------------------------------------|--------------------------|
| VPC              | Virtual Private Cloud                       | `10.0.0.0/16`            |
| Public Subnet    | For public-facing resources                 | `10.0.1.0/24` (eu-west-3a)|
| Private Subnet   | For internal backend resources              | `10.0.2.0/24` (eu-west-3b)|
| Internet Gateway | Enables internet access for public subnet  | Attached to VPC          |
| Route Table      | Routes `0.0.0.0/0` traffic to IGW          | Associated with public subnet |

---

### 2. **Compute**

| Instance       | Role              | Subnet Type | Key Features                                  |
|----------------|-------------------|-------------|-----------------------------------------------|
| Public EC2     | Admin Dashboard + Bastion Host | Public      | Public IP, SSH accessible from your IP, deploys admin UI|
| Private EC2    | Backend Apps      | Private     | No public IP, accessed via bastion, deploys developer, analyst, intern apps |

---

### 3. **Security**

- **Security Group:**  
  - SSH (port 22) allowed only from your trusted IP (`105.71.19.44/32`)  
  - HTTP (port 80) open to all  
  - All outbound traffic allowed  

- **IAM Setup:**  
  | Group       | Users              | Managed Policies                         | Purpose                    |
  |-------------|--------------------|----------------------------------------|----------------------------|
  | Admins      | oumaima.admin      | AdministratorAccess                    | Full AWS control           |
  | Developers  | marouane.dev       | AmazonEC2FullAccess                    | EC2 management             |
  | Analysts    | sara.analyst       | SecurityAudit                         | Security auditing          |
  | Interns     | laila.intern       | ReadOnlyAccess                        | Read-only permissions      |

---

### 4. **Logging & Compliance**

| Service          | Purpose                                      | Details                                             |
|------------------|----------------------------------------------|-----------------------------------------------------|
| AWS CloudTrail   | Logs API calls and user activity              | Multi-region, log validation enabled, logs to S3 bucket|
| S3 Bucket        | Centralized log storage                        | Versioned, bucket policy allowing CloudTrail writes |
| AWS Config       | Tracks resource configurations & compliance   | Records all supported resource types, delivery to S3|
| Config Rule      | Enforces resource tagging                      | Checks presence of `Name` tag on resources          |

---

## 🚀 Deployment Instructions

### Prerequisites

- Install [Terraform](https://www.terraform.io/downloads)
- AWS CLI configured with appropriate IAM permissions
- Your SSH private key file `key.pem` saved locally and secure
- Adjust your IP in the security group ingress rule if needed

### Steps

```bash
terraform init
terraform plan
terraform apply
