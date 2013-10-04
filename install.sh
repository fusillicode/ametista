
# Install Composer
php -r "eval('?>'.file_get_contents('https://getcomposer.org/installer'));"

# Remove already present vendor directory to cleanly install Predis package
rm -rf vendor

# Update Composer to install/update PHP-Parser and Predis packages
composer update

# Install Redis in vendor subdirectory
cd vendor
wget http://download.redis.io/releases/redis-2.6.16.tar.gz
tar xzf redis-2.6.16.tar.gz
cd redis-2.6.16
make
make test
