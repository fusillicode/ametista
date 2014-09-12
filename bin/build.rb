require 'mongoid'
Mongoid.load!('./mongoid.yml', :development)
Mongoid::Config.purge!

if __FILE__ == $0
  require_relative '../lib/inferer/mongo_daemon'
  mongo_daemon = MongoDaemon.new.start
  require_relative '../lib/inferer/builders/model_builder'
  model_builder = ModelBuilder.new.build
end
