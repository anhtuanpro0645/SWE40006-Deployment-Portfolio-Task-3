# SWE40006 - Task 3: Cloud Application Deployment & Infrastructure Scaling on AWS

This repository contains the initialization scripts and infrastructure documentation for a
WordPress deployment on AWS, built up through four progressive levels (Pass -> High Distinction).
All infrastructure was provisioned manually through the AWS Management Console and AWS CLI /
CloudShell, following a security-first provisioning order (security groups created before the
resources they protect). The scripts in this repository reconstruct the exact commands executed
on each resource so the deployment can be reproduced or audited.

> **Note on IaC tooling:** this deployment was provisioned directly via the AWS Console and CLI
> rather than Terraform/CloudFormation. The scripts below are the actual shell commands run on
> each EC2 instance (via SSH in Task 3.1-3.2, and AWS Systems Manager Session Manager from
> Task 3.3 onward) and are provided here for reproducibility and transparency, as required by the
> assignment submission guidelines.

## Architecture overview

| Layer | Service | Notes |
|---|---|---|
| Network | Custom VPC `10.0.0.0/16`, 2 Availability Zones, 2 public + 2 private subnets | No NAT Gateway - outbound access to AWS services from private subnets is via VPC Gateway/Interface Endpoints (S3, SSM, SSMMESSAGES, EC2MESSAGES) |
| Compute (3.1) | Single EC2 instance (Amazon Linux 2023), Apache + PHP + MariaDB (LAMP), WordPress | Public subnet |
| Database (3.2) | Amazon RDS for MySQL, Single-AZ, private subnet, DB Subnet Group across 2 AZs | Migrated from local MariaDB via `mysqldump` |
| Storage (3.2) | S3 bucket, Block Public Access ON, Versioning ON, SSE-S3 encryption | Manual backup of DB dump + web content |
| Scaling (3.3) | Custom AMI -> Launch Template -> Auto Scaling Group (min 2 / max 4, 2 AZ) behind an Application Load Balancer (HTTP:80) | Instances moved to private subnets; only the ALB is internet-facing |
| Security & Monitoring (3.4) | SSH fully removed from the web-tier security group; access exclusively via AWS Systems Manager Session Manager (IAM-based, no keys). CloudWatch Alarm (Average CPU > 70%) -> SNS Topic -> Email | |

Security group chaining: `ALB-SG (0.0.0.0/0:80)` -> `Web-tier-SG (80 from ALB-SG only, no SSH)` -> `RDS-SG (3306 from Web-tier-SG only)`.

## Repository structure

```
scripts/
  01-ec2-lamp-wordpress-setup.sh   # Task 3.1 - LAMP stack + WordPress install on EC2
  02-wp-config-setup.sh            # Task 3.1 - wp-config.php database configuration
  03-rds-migration.sh              # Task 3.2 - export local DB and import into RDS
  04-alb-siteurl-update.sh         # Task 3.3 - point WordPress site URL at the ALB DNS name
  05-loadbalancing-verification.sh # Task 3.3 - per-instance marker files to prove ALB round-robin
  06-aws-cli-verification.sh       # Task 3.2-3.4 - AWS CLI commands used to verify each resource
```

## Live verification (for grading)

- **Application Load Balancer DNS name:** `swe40006-alb-2043040907.us-east-1.elb.amazonaws.com`
- Access the site at: `http://swe40006-alb-2043040907.us-east-1.elb.amazonaws.com/`
- Load-balancing proof endpoint: `http://swe40006-alb-2043040907.us-east-1.elb.amazonaws.com/whoami.html` (refresh a few times - response alternates between the two Auto Scaling Group instances)

> Note: as this is a personal/free-tier AWS account, resources may be terminated after the
> submission window to avoid ongoing charges. If the lecturer needs a live re-demonstration
> after that point, please contact me and I can redeploy from these scripts within ~15-20 minutes.

## Security notes

- No private keys, `.pem`/`.ppk` files, or real passwords are committed to this repository.
- All placeholder credentials in the scripts below (e.g. `<DB_PASSWORD>`) must be replaced before
  execution.
- Port 22 (SSH) is not open on any resource past Task 3.3 - all administrative access is via
  SSM Session Manager, authenticated through the `swe40006-ec2-ssm-role` IAM role.
