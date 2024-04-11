# linux-LEMP-ubuntu-22
quick setup for a linux vm running php 7.4, nginx, mysql and wordpress

### install php
```
sudo apt-get update
sudo apt -y install software-properties-common
sudo add-apt-repository ppa:ondrej/php
sudo apt-get update
sudo apt -y install php7.4
sudo apt-get install -y php7.4-cli php7.4-json php7.4-common php7.4-mysql php7.4-zip php7.4-gd php7.4-mbstring php7.4-curl php7.4-xml php7.4-bcmath
sudo apt install php7.4-fpm
```

### disable apache2
```
sudo update-rc.d apache2 disable
sudo service apache2 stop
```

### remove nginx [if installed]
```
sudo apt remove --purge nginx*
sudo apt autoremove
```

### install nginx
```
sudo apt update
sudo apt -y install nginx
```

### make sure nginx is working
```
sudo vi /etc/nginx/sites-enabled/default

// edit the index line below `root /var/www/html` to be:
index index.nginx-debian.html;

// restart nginx 
sudo service nginx restart

// hit localhost:80 and you should see `Welcome to nginx` ui
```

### install mysql
```
sudo apt install -y mysql-server

// enter mysql server
sudo mysql

// create a database named "dev-local"
CREATE DATABASE IF NOT EXISTS dev;

// create wordpress user for db access
CREATE USER dev@localhost identified by 'password';
GRANT ALL PRIVILEGES ON dev.* TO 'dev'@'localhost' WITH GRANT OPTION;

```

### install wordpress
```
// cd into your project root i.e. /var/www/dev.local
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzvf latest.tar.gz
sudo rm latest.tar.gz
cd wordpress
```

### config wp db connect params
```
sudo cp wp-config-sample.php wp-config.php
sudo vi wp-config.php
```
modify the values in php file :
```
define( 'DB_NAME', 'dev' );
define( 'DB_USER', 'dev' ); 
define( 'DB_PASSWORD', 'password' );
```

### update directory group recursively
```
cd /var/www/
sudo chown www-data:www-data -R dev
```

### create custom site nginx config
```
sudo vi /etc/nginx/sites-available/dev.local.conf
```

### dev.local.conf
```
upstream dev-php-handler {
    server unix:/var/run/php/php7.4-fpm.sock;
}

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
        #NOTE: You should have "cgi.fix_pathinfo = 0;" in php.ini
        include snippets/fastcgi-php.conf;
        fastcgi_pass dev-php-handler;
    }

    location ~ /\.ht {
        deny all;
    }
}
```

### symlink site to sites-enabled
```
sudo ln -s /etc/nginx/sites-available/dev.local.conf /etc/nginx/sites-enabled/
```

### modify `C:\Windows\System32\drivers\etc\hosts` on Windows side
```
127.0.0.1     dev.local
```

### init wordpress
- hit `http://dev.local` in browser
