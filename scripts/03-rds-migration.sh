#!/bin/bash
# Task 3.2 (Credit) - Migrate the local MariaDB database to Amazon RDS
# Run on the EC2 instance (Task 3.1 host) via SSH.

set -e

RDS_ENDPOINT="<RDS_ENDPOINT>"        # e.g. swe40006-db.xxxxxxxxxx.us-east-1.rds.amazonaws.com
RDS_MASTER_USER="admin"
DB_NAME="wordpress_db"

# --- 1. Dump the local database (source snapshot, before migration) ---
sudo mysqldump -u root "$DB_NAME" > wordpress_backup.sql

# --- 2. Import the dump into the RDS instance ---
# You will be prompted for the RDS master password.
mysql -h "$RDS_ENDPOINT" -u "$RDS_MASTER_USER" -p "$DB_NAME" < wordpress_backup.sql

# --- 3. (Optional) take a second dump directly FROM RDS after migration,
#         useful as a "post-migration" backup / evidence pair ---
mysqldump -h "$RDS_ENDPOINT" -u "$RDS_MASTER_USER" -p "$DB_NAME" > wordpress_backup_rds.sql

# --- 4. Point WordPress at the RDS instance instead of the local DB ---
cd /var/www/html
sudo sed -i "s/'DB_HOST', 'localhost'/'DB_HOST', '$RDS_ENDPOINT'/" wp-config.php
sudo sed -i "s/'DB_USER', 'wp_user'/'DB_USER', '$RDS_MASTER_USER'/" wp-config.php
# Replace <RDS_PASSWORD> below with the actual RDS master password.
sudo python3 -c "
import re
f = '/var/www/html/wp-config.php'
c = open(f).read()
c = re.sub(r\"'DB_PASSWORD', '[^']*'\", \"'DB_PASSWORD', '<RDS_PASSWORD>'\", c)
open(f, 'w').write(c)
"

echo "Database migrated to RDS ($RDS_ENDPOINT). Verify by reloading the WordPress site."
