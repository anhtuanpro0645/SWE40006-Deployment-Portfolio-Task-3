#!/bin/bash
# Task 3.3 (Distinction) - Point WordPress at the Application Load Balancer's
# DNS name, so instances launched by the Auto Scaling Group (from a Golden
# AMI baked from this configuration) always resolve links correctly.
# Run on the EC2 instance BEFORE creating the Golden AMI.

set -e

ALB_DNS="<ALB_DNS_NAME>"   # e.g. swe40006-alb-2043040907.us-east-1.elb.amazonaws.com

sudo sed -i "/\/\* That's all, stop editing/i \\
define('WP_HOME','http://$ALB_DNS');\\
define('WP_SITEURL','http://$ALB_DNS');" /var/www/html/wp-config.php

echo "WP_HOME / WP_SITEURL set to http://$ALB_DNS"
echo "Next: EC2 Console -> Actions -> Image and templates -> Create image, to bake the Golden AMI."
