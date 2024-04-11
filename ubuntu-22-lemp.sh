#!/bin/bash

# Install PHP
sudo apt-get update
sudo apt -y install software-properties-common
sudo add-apt-repository -y ppa:ondrej/php
sudo apt-get update
sudo apt -y install php7.4
sudo apt-get install -y php7.4-cli php7.4-json php7.4-common php7.4-mysql php7.4-zip php7.4-gd php7.4-mbstring php7.4-curl php7.4-xml php7.4-bcmath
sudo apt -y install php7.4-fpm

# Disable Apache2
sudo update-rc.d apache2 disable
sudo service apache2 stop

# Install Nginx
sudo apt update
sudo apt -y install nginx

# Ensure Nginx is working
sudo sed -i 's/index index\.html index\.htm index\.nginx-debian.html;/index index.php index.nginx-debian.html;/' /etc/nginx/sites-enabled/default
sudo service nginx restart

# Install MySQL
sudo apt install -y mysql-server

# Create MySQL Database and User
sudo mysql -e "CREATE DATABASE IF NOT EXISTS dev;"
sudo mysql -e "CREATE USER 'dev'@'localhost' IDENTIFIED BY 'password';"
sudo mysql -e "GRANT ALL PRIVILEGES ON dev.* TO 'dev'@'localhost' WITH GRANT OPTION;"

# Install WordPress
sudo mkdir /var/www/dev.local
cd /var/www/dev.local
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzvf latest.tar.gz
sudo rm latest.tar.gz
cd wordpress

# Configure WordPress database connection
sudo cp wp-config-sample.php wp-config.php
sudo sed -i "s/database_name_here/dev/" wp-config.php
sudo sed -i "s/username_here/dev/" wp-config.php
sudo sed -i "s/password_here/password/" wp-config.php

# Update directory group recursively
sudo chown www-data:www-data -R /var/www/dev.local

# Add shared upstream to handle PHP files in the Nginx configuration file
sudo sed -i '1i upstream dev-php-handler {\n    server unix:/var/run/php/php7.4-fpm.sock;\n}' /etc/nginx/sites-enabled/default

# Create custom Nginx configuration
sudo tee /etc/nginx/sites-available/dev.local.conf > /dev/null <<'EOF'

server {
    listen 80;

    access_log /var/log/nginx/dev.local-access.log;
    error_log /var/log/nginx/dev.local-error.log;

    server_name dev.local www.dev.local;
    root /var/www/dev/wordpress;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass dev-php-handler;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

# Symlink site to sites-enabled
sudo ln -s /etc/nginx/sites-available/dev.local.conf /etc/nginx/sites-enabled/

# Restart Nginx
sudo service nginx restart

# Display instructions to initialize WordPress
echo "Please open http://dev.local in your browser to complete WordPress setup. -gartril the dwarven engineer"

