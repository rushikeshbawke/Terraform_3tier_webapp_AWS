# AWS 3-Tier Web Application Infrastructure via Terraform

An end-to-end, production-grade Infrastructure-as-Code (IaC) repository that provisions a secure, highly available, and scalable 3-tier web application architecture on AWS using Terraform.

This project demonstrates core DevOps principles including modular infrastructure design, automated scaling, multi-AZ high availability, end-to-end security, and automated monitoring.

---

## Deep-Dive Architecture & Traffic Flow

The architecture follows AWS best practices for a multi-tier, highly available, and secure production environment.

### 1. Edge & Content Delivery Tier
* **Amazon Route 53:** Serves as the primary DNS service, routing global user requests with low latency.
* **Amazon CloudFront:** Acts as the global Content Delivery Network (CDN), caching static assets at edge locations to minimize latency and reduce origin load.

### 2. Presentation / Web Tier (Public Subnets)
* **Application Load Balancer (ALB):** Positioned across multiple Availability Zones in public subnets to distribute incoming HTTP/HTTPS traffic dynamically. Conducts continuous health checks to direct traffic only to healthy compute instances.
* **Auto Scaling Group (ASG) - Web Servers:** Dynamically scales EC2 web instances across Availability Zones (AZ-1a, AZ-1b) based on demand metrics, ensuring fault tolerance and high availability.
* **NAT Gateways:** Provisioned in public subnets to allow instances in private subnets outbound internet access (e.g., for software updates/patches) without exposing them to inbound internet traffic.

### 3. Application Tier (Private Subnets)
* **Internal ALB & ASG - App Servers:** Receives traffic exclusively from the web tier via strict Security Group rules. Houses core business logic isolated from direct public internet exposure.

### 4. Data Tier (Isolated Subnets)
* **Amazon RDS (Multi-AZ):** Provisions a Primary database in one AZ and maintains a synchronous Standby/Backup replica in a second AZ for automatic failover and high reliability.
* **Amazon S3:** Dedicated storage buckets for static object hosting, application state backups, and VPC Flow Logs.

### 5. Security & Observability Layer
* **IAM Roles & Policies:** Enforces the principle of least privilege for EC2 instance profiles and AWS service integrations.
* **AWS CloudTrail & VPC Flow Logs:** Captures continuous API audit trails and network traffic logs stored securely in S3.
* **Amazon CloudWatch & SNS:** Real-time infrastructure metric collection and automated alarm notifications dispatched to administrators via SNS topics.

---

<img width="1580" height="812" alt="Architecture-diagram" src="https://github.com/user-attachments/assets/6afd66ab-6384-4aa6-8712-2d3bc11e7522" />

---

## Prerequisites

- [Terraform CLI](https://www.terraform.io/) >= 1.0.0
- [AWS CLI](https://aws.amazon.com/cli/) configured with `AdministratorAccess` or appropriate IAM permissions
- Active [AWS Account](https://aws.amazon.com/)
- Configured SSH Key Pair for EC2 access

---

## Versions & Dependencies

| Tool / Resource | Target Version / Provider |
| :--- | :--- |
| Terraform | `>= 1.0.0` |
| AWS Provider | `~> 5.0` |
| Cloud Architecture | 3-Tier VPC Architecture |

---

## Key Skills & AWS Services Demonstrated

| Skill & AWS Service | Capability & Architectural Responsibility | Relevant Terraform File |
| :--- | :--- | :--- |
| **AWS VPC & Networking** | Multi-AZ subnet isolation, NAT Gateways, Internet Gateways, and Route Tables for secure network boundaries. | `vpc.tf` |
| **AWS Security Groups** | Stateful firewall rules enforcing least-privilege access across Load Balancers, EC2, RDS, and S3. | `security_group.tf` |
| **AWS ALB & EC2 ASG** | High availability, automated health checks, dynamic auto-scaling, and zero-downtime traffic distribution. | `alb.tf` & `asg.tf` |
| **Amazon RDS (Data Tier)** | Relational database provisioning with Multi-AZ failover and encrypted subnet management. | `rds.tf` |
| **AWS CloudFront & Route 53** | Low-latency global content delivery (CDN), custom domain routing, and edge caching. | `cloudfront_route53.tf` |
| **AWS IAM & Security** | Fine-grained identity access management, role delegation, instance profiles, and policy enforcement. | `iam.tf` |
| **AWS Observability** | Centralized metric logging (CloudWatch), governance auditing (CloudTrail), and real-time alert dispatching (SNS). | `cloudwatch.tf`, `cloudtrail.tf`, `sns.tf` |

---

## Key Operational Outputs

Upon executing `terraform apply`, the configuration exports the following operational endpoints and resource identifiers:

* **`alb_dns_name`**: Public entry point managed by the Application Load Balancer for incoming HTTP/HTTPS web traffic.
* **`cloudfront_domain_name`**: Low-latency CDN edge endpoint serving static web assets and distribution files.
* **`rds_endpoint`**: Private network connection string for database queries originating from the compute tier.
* **`s3_bucket_name`**: Globally unique storage bucket identifier for static website assets and backend log state.
* **`sns_topic_arn`**: Amazon Resource Name (ARN) configured for CloudWatch metrics and real-time operational notifications.

## Repository Structure

```text
Terraform_3tier_webapp_AWS/
├── vpc.tf                # VPC, Public/Private Subnets, NAT Gateways, Route Tables
├── security_group.tf     # Security Groups for ALB, EC2, RDS, and S3 access
├── alb.tf                # Application Load Balancer, Listener Rules, Target Groups
├── asg.tf                # Launch Template & Auto Scaling Group setup
├── rds.tf                # Multi-AZ Relational Database Instance & Subnet Groups
├── s3.tf                 # S3 Buckets for static hosting and state/logs
├── cloudfront_route53.tf # CloudFront CDN setup & Route53 DNS routing
├── iam.tf                # IAM Roles, Instance Profiles, and Least-Privilege Policies
├── cloudwatch.tf         # CloudWatch Alarms & Metric Filters for monitoring
├── cloudtrail.tf         # AWS CloudTrail for governance and API auditing
├── sns.tf                # SNS Topics & Subscriptions for real-time alerts
├── variables.tf          # Input variable definitions and defaults
├── outputs.tf            # Operational outputs (Endpoints, IDs, DNS names)
└── versions.tf           # Required Terraform and Provider versions



