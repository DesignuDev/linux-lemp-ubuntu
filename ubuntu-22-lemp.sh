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
sudo systemctl stop apache2

# Install Nginx
sudo apt update
sudo apt -y install nginx

# Ensure Nginx is working
#sudo sed -i 's/index index\.html index\.htm index\.nginx-debian.html;/index index.php index.nginx-debian.html;/' /etc/nginx/sites-enabled/default

# Install MySQL
sudo apt install -y mysql-server

# Create MySQL Database and User
sudo mysql -e "CREATE DATABASE IF NOT EXISTS dev;"
sudo mysql -e "CREATE USER 'dev'@'localhost' IDENTIFIED BY 'password';"
sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'dev'@'localhost' WITH GRANT OPTION;"

# Update directory group recursively
sudo chown www-data:www-data -R /var/www/

# Setup user directory with correct permissions
sudo chmod -R 755 ~

# Update the user that nginx and php runs as
USERNAME=$(whoami)
sudo sed -i "s/^user .*;/user $USERNAME;/" /etc/nginx/nginx.conf
sudo sed -i "s/^user = .*/user = $USERNAME/" /etc/php/7.4/fpm/pool.d/www.conf
sudo sed -i "s/^group = .*/group = $USERNAME/" /etc/php/7.4/fpm/pool.d/www.conf

# Move the default file to sites-available instead of sites-enabled
sudo mv /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default

# Add shared upstream to handle PHP files in the Nginx configuration file
sudo sed -i '1i upstream dev-php-handler {\n    server unix:/var/run/php/php7.4-fpm.sock;\n}' /etc/nginx/sites-available/default

# Replace sites enabled to sites available so we only have to make one config
sudo sed -i 's|include /etc/nginx/sites-enabled/\*;|include /etc/nginx/sites-available/\*;|' /etc/nginx/nginx.conf

# Remove the sites-enabled folder
sudo rmdir /etc/nginx/sites-enabled

# Create custom Nginx configuration
sudo tee /etc/nginx/sites-available/dev.mysite.conf > /dev/null <<'EOF'

server {
    listen 80;

    access_log /var/log/nginx/dev.mysite-access.log;
    error_log /var/log/nginx/dev.mysite-error.log;

    server_name dev.mysite www.dev.mysite;
    root /home/<USER>/sites/dev.mysite;
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

# Restart Nginx
sudo systemctl restart nginx
sudo systemctl restart php7.4-fpm

# Display instructions to initialize WordPress
echo "--------------------------------------------"
echo "--------------------------------------------"
echo " ||   You are surrounded by darkness...  || "
echo "--------------------------------------------"
echo "--------------------------------------------"
echo "    you hold onto the only light that has and will forever guide you through the chaos, your soul."
echo "  Lightning strikes and for a few seconds you manage to catch a glimpse of a damp wooden sign-"
echo "    it has carvings etched into it, it reads:"
echo "--------------------------------------------"
echo " ||           http://dev.local            ||"
echo "--------------------------------------------"
echo "You're reminded of Gartril, a dwarven engineer..."
echo "  betrayed by friends and kin alike, mistaken for a monster,"
echo "  and true forever to his naive soul--"
echo "  "
echo " he used to make good pancakes."
echo "   and will forever be--"
echo " "
echo "  ONE MAN"
echo "  ALONE..."
echo "  BETRAYED BY THE COUNTRIES HE LOVES"
echo "            _____  .__        .__        ";
echo "           /     \ |__| _____ |__| ____  ";
echo "  ______  /  \ /  \|  |/     \|  |/ ___\ ";
echo " /_____/ /    Y    \  |  Y Y  \  \  \___ ";
echo "         \____|__  /__|__|_|  /__|\___  >";
echo "                 \/         \/        \/ ";