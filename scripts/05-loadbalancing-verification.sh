#!/bin/bash
# Task 3.3 (Distinction) - Load balancing verification
# Run separately on EACH Auto Scaling Group instance via SSM Session Manager,
# with a different label per instance, then repeatedly refresh
# http://<ALB_DNS>/whoami.html in a browser. The response should alternate
# between instances, proving the ALB is distributing traffic across the
# target group rather than sending all traffic to a single target.

set -e

INSTANCE_LABEL="<Instance 1 | Instance 2>"   # set uniquely per instance

sudo bash -c "echo '<h1>Response from $INSTANCE_LABEL - \$(hostname -I)</h1>' > /var/www/html/whoami.html"

echo "Marker file written. Test at http://<ALB_DNS>/whoami.html"
