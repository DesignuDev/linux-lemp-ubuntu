#!/bin/bash

# Install PHP
sudo dpkg -l | grep php | tee packages.txt
sudo add-apt-repository ppa:ondrej/php # Press enter when prompted.
sudo apt update
sudo apt -y install php8.2 php8.2-cli php8.2-{bz2,curl,mbstring,intl,mysqli}
sudo apt -y install php8.2-fpm
sudo a2enconf php8.2-fpm

# Disable Apache2
sudo update-rc.d apache2 disable
sudo systemctl stop apache2

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

# Update directory group recursively
sudo chown www-data:www-data -R /var/www/

# Setup user directory with correct permissions
sudo chmod -R 755 ~

# Update the user that nginx and php runs as
USERNAME=$SUDO_USER
sudo sed -i "s/^user .*;/user $USERNAME;/" /etc/nginx/nginx.conf
sudo sed -i "s/^user = .*/user = $USERNAME/" /etc/php/8.2/fpm/pool.d/www.conf
sudo sed -i "s/^group = .*/group = $USERNAME/" /etc/php/8.2/fpm/pool.d/www.conf

# Make Sites directory
mkdir /home/$USERNAME/sites/

#Add User to www-data group
sudo usermod -aG www-data $USERNAME

# Move the default file to sites-available instead of sites-enabled
sudo mv /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default

# Add shared upstream to handle PHP files in the Nginx configuration file
sudo sed -i '1i upstream dev-php-handler {\n    server unix:/var/run/php/php8.2-fpm.sock;\n}' /etc/nginx/sites-available/default

# Replace sites enabled to sites available so we only have to make one config
sudo sed -i 's|include /etc/nginx/sites-enabled/\*;|include /etc/nginx/sites-available/\*;|' /etc/nginx/nginx.conf

# Remove the sites-enabled folder
sudo rm -R /etc/nginx/sites-enabled/

# Create custom Nginx configuration
sudo -E bash -c "cat > /etc/nginx/sites-available/dev.mysite.conf" <<EOF

server {
    listen 80;

    access_log /var/log/nginx/dev.mysite-access.log;
    error_log /var/log/nginx/dev.mysite-error.log;

    server_name dev.mysite www.dev.mysite;
    root /home/$USERNAME/sites/dev.mysite;
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
sudo systemctl restart php8.2-fpm

# Log complete
echo "Script Complete"
echo "Original script by Mimic"