#!/bin/bash
# Task 3.2 - 3.4 - AWS CLI verification commands, run from AWS CloudShell
# (or a local machine with the AWS CLI configured against the swe40006-admin
# IAM user). These commands were used to independently verify every major
# resource alongside the AWS Console evidence in the report.

# --- VPC ---
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=swe40006-vpc"

# --- RDS ---
aws rds describe-db-instances --db-instance-identifier swe40006-db

# --- Application Load Balancer ---
aws elbv2 describe-load-balancers --names swe40006-alb

# --- Target Group health (both ASG instances should be "healthy") ---
aws elbv2 describe-target-health \
  --target-group-arn "$(aws elbv2 describe-target-groups \
      --names swe40006-tg \
      --query 'TargetGroups[0].TargetGroupArn' \
      --output text)"

# --- Auto Scaling Group ---
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names swe40006-asg

# --- CloudWatch Alarm ---
aws cloudwatch describe-alarms --alarm-names swe40006-high-cpu-alarm

# --- (Optional) Manually trigger the alarm to test the SNS -> Email pipeline ---
# aws cloudwatch set-alarm-state \
#   --alarm-name "swe40006-high-cpu-alarm" \
#   --state-value ALARM \
#   --state-reason "Testing SNS email notification pipeline"
#
# aws cloudwatch set-alarm-state \
#   --alarm-name "swe40006-high-cpu-alarm" \
#   --state-value OK \
#   --state-reason "Reset after testing"
