
# Install Composer
php -r "eval('?>'.file_get_contents('https://getcomposer.org/installer'));"

# Remove already present vendor directory to cleanly install vendors stuff
rm -rf vendor

# Update Composer to install/update PHP-Parser and Predis libs
php composer.phar install
php composer.phar update

# Install Redis in vendor subdirectory
REDIS_VERSION="2.8.19"
REDIS="redis-$REDIS_VERSION"
REDIS_PACKAGE="$REDIS.tar.gz"
cd vendor
wget "http://download.redis.io/releases/$REDIS_PACKAGE"
tar xzf "$REDIS_PACKAGE"
cd "$REDIS"
make
cd ..
mv "$REDIS" redis
cd ..

# Install required Gems
bundle install
