if __FILE__ == $0
  require 'mongoid'
  require_relative '../lib/inferer/mongo_daemon'
  require_relative '../lib/inferer/builders/model_builder'
  mongo_daemon = MongoDaemon.new.start
  Mongoid.load!('./mongoid.yml', :development)
  Mongoid::Config.purge!
  model_builder = ModelBuilder.new.build
end
