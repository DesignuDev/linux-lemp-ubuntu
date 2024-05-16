# Install WordPress
sudo mkdir /var/www/dev.wordpress
cd /var/www/dev.wordpress
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
sudo chown www-data:www-data -R /var/www/dev.wordpress