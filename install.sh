
# Install Composer
php -r "eval('?>'.file_get_contents('https://getcomposer.org/installer'));"

# Remove already present vendor directory to cleanly install Predis package
rm -rf vendor

# Update Composer to install/update PHP-Parser and Predis packages
php composer.phar install
php composer.phar update

# Install Redis in vendor subdirectory
REDIS_VERSION="2.8.5"
REDIS="redis-$REDIS_VERSION"
REDIS_PACKAGE="$REDIS.tar.gz"
cd vendor
wget "http://download.redis.io/releases/$REDIS_PACKAGE"
tar xzf "$REDIS_PACKAGE"
cd "$REDIS"
make
cd ../..

# Install MongoDb in vendor subdirectory
cd vendor
case `uname -s` in
  Linux*)
    PLATFORM="linux"
    ;;
  Darwin*)
    PLATFORM="osx"
    ;;
  *)
    echo "unknown: $OSTYPE"
    exit 1
    ;;
esac
MONGODB_VERSION="2.6.3"
MONGODB="mongodb-$PLATFORM-x86_64-$MONGODB_VERSION"
MONGODB_PACKAGE="$MONGODB.tgz"
curl -O "http://downloads.mongodb.org/$PLATFORM/$MONGODB_PACKAGE"
tar -zxvf "$MONGODB_PACKAGE"

# Install required Gems
bundle install

