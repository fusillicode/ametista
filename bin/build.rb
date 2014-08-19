require_relative '../lib/inferer/mongo_daemon'
require_relative '../lib/inferer/schema'
require_relative '../lib/inferer/builders/model_builder'

if __FILE__ == $0
  mongo_daemon = MongoDaemon.new.start
  Mongoid.load!('./mongoid.yml', :development)
  Mongoid::Config.purge!
  model_builder = ModelBuilder.new.build
  # p AType.all.count
  Namespace.all.each do |namespace|
    p namespace.unique_name
    p namespace.assignements
  end
end
