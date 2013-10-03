
# Install Composer
php -r "eval('?>'.file_get_contents('https://getcomposer.org/installer'));"

# Update Composer to install/update PHP-Parser and Predis packages
composer update

# Install Redis in vendor subdirectory
cd vendor
wget http://download.redis.io/releases/redis-2.6.16.tar.gz
tar xzf redis-2.6.16.tar.gz
cd redis-2.6.16
make
