#!/bin/bash

# Install PHP 8.4 (Ondřej PPA)
sudo dpkg -l | grep php | tee packages.txt
sudo add-apt-repository -y ppa:ondrej/php
sudo apt update
sudo apt -y install php8.4 php8.4-cli php8.4-{bz2,curl,mbstring,intl,mysql,xml,zip,gd}
sudo apt -y install php8.4-fpm

# Disable Apache2
sudo update-rc.d apache2 disable || true
sudo systemctl stop apache2 || true

# Install Nginx
sudo apt update
sudo apt -y install nginx

# Ensure Nginx is working
sudo sed -i 's/index index\.html index\.htm index\.nginx-debian.html;/index index.php index.nginx-debian.html;/' /etc/nginx/sites-enabled/default

# Install MySQL
sudo apt install -y mysql-server

# Create MySQL Database and User
sudo mysql -e "CREATE DATABASE IF NOT EXISTS dev;"
sudo mysql -e "CREATE USER 'dev'@'localhost' IDENTIFIED BY 'password';"
sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'dev'@'localhost' WITH GRANT OPTION;"

# Setup user directory with correct permissions
sudo chmod -R 755 ~

# Update the user that nginx and php runs as
USERNAME=$SUDO_USER
sudo sed -i "s/^user .*;/user $USERNAME;/" /etc/nginx/nginx.conf
sudo sed -i "s|^user = .*|user = $USERNAME|" /etc/php/8.4/fpm/pool.d/www.conf
sudo sed -i "s|^group = .*|group = $USERNAME|" /etc/php/8.4/fpm/pool.d/www.conf

# Make Sites directory
mkdir -p /home/$USERNAME/sites/
sudo chown -R $USERNAME:$USERNAME /home/$USERNAME/sites/

# Add User to www-data group
sudo usermod -aG www-data $USERNAME

# Move the default file to sites-available instead of sites-enabled
if [ -e /etc/nginx/sites-enabled/default ]; then
  sudo mv /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default
fi

# Add shared upstream to handle PHP files in the Nginx configuration file (PHP 8.4 socket)
if ! grep -q "upstream dev-php-handler" /etc/nginx/sites-available/default; then
  sudo sed -i '1i upstream dev-php-handler {\n    server unix:/var/run/php/php8.4-fpm.sock;\n}' /etc/nginx/sites-available/default
else
  sudo sed -i 's|unix:/var/run/php/php8\.2-fpm\.sock|unix:/var/run/php/php8\.4-fpm\.sock|' /etc/nginx/sites-available/default
fi

# Replace sites-enabled include with sites-available in nginx.conf
sudo sed -i 's|include /etc/nginx/sites-enabled/\*;|include /etc/nginx/sites-available/\*;|' /etc/nginx/nginx.conf

# Remove the sites-enabled folder
sudo rm -rf /etc/nginx/sites-enabled/

# Create custom Nginx configuration
sudo tee /etc/nginx/sites-available/dev.example >/dev/null <<EOF
server {
    listen 80;

    access_log /var/log/nginx/dev.example-access.log;
    error_log /var/log/nginx/dev.example-error.log;

    server_name dev.example www.dev.example;
    root /home/${USERNAME}/sites/example;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
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

# Update upload limits
sudo tee /etc/nginx/conf.d/uploads.conf >/dev/null <<'EOF'
# Global limit for all server blocks
client_max_body_size 1G;
EOF

PHPINI="/etc/php/8.4/fpm/php.ini"
sudo sed -i "s|^upload_max_filesize = .*|upload_max_filesize = 1G|" "$PHPINI"
sudo sed -i "s|^post_max_size = .*|post_max_size = 1G|" "$PHPINI"

udo sed -i "s|^max_execution_time = .*|max_execution_time = 300|" "$PHPINI"
sudo sed -i "s|^memory_limit = .*|memory_limit = 1G|" "$PHPINI"

# Test Nginx config, restart services
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable --now php8.4-fpm
sudo systemctl restart php8.4-fpm

# Removing the random packages file that gets created
if [ -f /home/$USERNAME/packages.txt ]; then
    sudo rm /home/$USERNAME/packages.txt
fi

# Log complete
echo "Script Complete (PHP 8.4)"
echo "Original script by Mimic"
