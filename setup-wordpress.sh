# Install WordPress
wget https://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz
rm latest.tar.gz
cd wordpress
mv * ..
cd ..
rmdir wordpress

# Create Nginx config
USERNAME="${SUDO_USER:-$USER}"
SITE_ROOT="$(pwd)"
SITE_NAME="$(basename "$SITE_ROOT")"

# Add dev. to site name if it does not already exist
if [[ "$SITE_NAME" == dev.* ]]; then
  SITE_HOST="$SITE_NAME"
else
  SITE_HOST="dev.$SITE_NAME"
fi

DB_NAME="wp_${SITE_NAME//./_}"
DB_USER="dev"
DB_PASS="password"

sudo mysql -e "CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;"
sudo mysql -e "GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

ACCESS_LOG="/var/log/nginx/${SITE_HOST}-access.log"
ERROR_LOG="/var/log/nginx/${SITE_HOST}-error.log"

NGINX_SITE_FILE="/etc/nginx/sites-available/${SITE_HOST}"

sudo tee "$NGINX_SITE_FILE" >/dev/null <<EOF
server {
    listen 80;

    access_log ${ACCESS_LOG};
    error_log ${ERROR_LOG};

    server_name ${SITE_HOST};
    root ${SITE_ROOT};
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass dev-php-handler;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

sudo systemctl restart nginx.service

echo "Wordpress site installed"
echo "Nginx config created in ${NGINX_SITE_FILE}"
echo "MySQL-database '${DB_NAME}' created for user '${DB_USER}'"
