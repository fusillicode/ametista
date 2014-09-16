if __FILE__ == $0
  require 'mongoid'
  require_relative '../lib/inferer/mongo_daemon'
  mongo_daemon = MongoDaemon.new.start
  Mongoid.load!('./mongoid.yml', :development)
  Mongoid::Config.purge!
  require_relative '../lib/inferer/builders/model_builder'
  model_builder = ModelBuilder.new.build
end
