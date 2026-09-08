#!/bin/bash
# Task 3.1 (Pass) - Configure wp-config.php from the sample file
# Run on the EC2 instance, inside /var/www/html

set -e
cd /var/www/html

sudo cp wp-config-sample.php wp-config.php

# --- Database settings ---
sudo sed -i "s/database_name_here/wordpress_db/" wp-config.php
sudo sed -i "s/username_here/wp_user/" wp-config.php
# Note: the password below contains a "!" character. Bash performs history
# expansion (!) even inside double quotes - always use single quotes for
# passwords containing "!" or escape it, otherwise you will hit
# "-bash: event not found".
sudo sed -i 's/password_here/<DB_PASSWORD>/' wp-config.php
sudo sed -i "s/localhost/localhost/" wp-config.php   # DB_HOST stays localhost until Task 3.2

sudo chown apache:apache wp-config.php
sudo chmod 640 wp-config.php

# --- Restart services to apply ---
sudo systemctl restart httpd php-fpm

echo "wp-config.php configured. Complete the install via the browser setup wizard."
