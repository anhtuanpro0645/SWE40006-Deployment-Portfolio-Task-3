#!/bin/bash
# Task 3.1 (Pass) - LAMP stack + WordPress installation on Amazon Linux 2023
# Run on the EC2 instance via SSH (or SSM Session Manager).

set -e

# --- Update system packages ---
sudo dnf update -y

# --- Install Apache (httpd) ---
sudo dnf install -y httpd
sudo systemctl enable httpd
sudo systemctl start httpd

# --- Install PHP (php-fpm) ---
sudo dnf install -y php php-fpm php-mysqlnd php-json php-gd php-mbstring
sudo systemctl enable php-fpm
sudo systemctl start php-fpm

# --- Install MariaDB server ---
sudo dnf install -y mariadb105-server
sudo systemctl enable mariadb
sudo systemctl start mariadb

# --- Secure MariaDB and create WordPress database/user ---
# Replace <DB_PASSWORD> with a strong password before running.
sudo mysql -u root <<'SQL'
CREATE DATABASE IF NOT EXISTS wordpress_db;
CREATE USER IF NOT EXISTS 'wp_user'@'localhost' IDENTIFIED BY '<DB_PASSWORD>';
GRANT ALL PRIVILEGES ON wordpress_db.* TO 'wp_user'@'localhost';
FLUSH PRIVILEGES;
SQL

# --- Download and deploy WordPress ---
cd /tmp
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
sudo cp -r wordpress/* /var/www/html/
sudo chown -R apache:apache /var/www/html
sudo chmod -R 755 /var/www/html

echo "LAMP stack + WordPress files deployed. Next: run 02-wp-config-setup.sh"
