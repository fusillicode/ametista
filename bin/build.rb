require 'mongoid'
Mongoid.load!('./mongoid.yml', :development)
require_relative '../lib/inferer/mongo_daemon'
require_relative '../lib/inferer/builders/model_builder'

if __FILE__ == $0
  mongo_daemon = MongoDaemon.new.start
  Mongoid::Config.purge!
  model_builder = ModelBuilder.new.build
end
