# AWS 3-Tier Web Application Infrastructure via Terraform

An end-to-end, production-grade Infrastructure-as-Code (IaC) repository that provisions a secure, highly available, and scalable 3-tier web application architecture on AWS using Terraform.

This project demonstrates core DevOps principles including modular infrastructure design, automated scaling, multi-AZ high availability, end-to-end security, and automated monitoring.

---

## Architecture Overview

- **Presentation Layer:** Amazon CloudFront distribution paired with AWS Route53 for Global Content Delivery (CDN) and DNS management.
- **Application / Compute Layer:** Application Load Balancer (ALB) routing incoming web traffic across an Auto Scaling Group (ASG) of EC2 instances spanning multiple Availability Zones.
- **Data Layer:** Multi-AZ Amazon RDS (Relational Database Service) for structured storage and Amazon S3 for static object storage.
- **Observability & Security:** Comprehensive logging and auditing via AWS CloudWatch, CloudTrail, IAM fine-grained policies, and automated alerting via SNS.

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
Key Skills & AWS Services DemonstratedCompetency / FeatureRelevant Terraform FileNetwork Isolation & Multi-AZ VPCvpc.tfStateful Security & Traffic Controlsecurity_group.tfHigh Availability & Load Balancingalb.tf & asg.tfDatabase Provisioning & Resiliencerds.tfCDN & Custom Domain Routingcloudfront_route53.tfIdentity & Access Management (IAM)iam.tfEnterprise Auditability & Loggingcloudwatch.tf, cloudtrail.tf, sns.tfDeployment Guide1. Prerequisites SetupClone the repository and initialize the working directory:Bashgit clone [https://github.com/rushikeshbawke/Terraform_3tier_webapp_AWS.git](https://github.com/rushikeshbawke/Terraform_3tier_webapp_AWS.git)
cd Terraform_3tier_webapp_AWS
terraform init
2. Plan InfrastructureReview the proposed execution plan to verify resource creation:Bashterraform plan
3. DeployApply the configuration to provision the 3-tier environment on AWS:Bashterraform apply -auto-approve
4. TeardownTo destroy all provisioned infrastructure and avoid unnecessary cloud costs:Bashterraform destroy -auto-approve
Key Operational OutputsUpon successful deployment, Terraform exports key operational endpoints:alb_dns_name: Public URL of the Application Load Balancercloudfront_domain_name: CDN Endpoint for fast asset deliveryrds_endpoint: Private Database Connection Endpoint
