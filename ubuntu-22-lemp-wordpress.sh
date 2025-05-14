# Install WordPress
wget https://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz
rm latest.tar.gz
cd wordpress
mv * ..
cd ..
rmdir wordpress

echo "Remember to add config to Nginx!"
echo "/etc/nginx/sites-available/dev.mysite"
echo ""
echo "Remember to add a database to the MySQL server!"
echo "Use DBeaver or CLI"
echo ""

# Add config to Nginx (Add later)