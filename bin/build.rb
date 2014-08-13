require_relative 'mongo_daemon'
require_relative 'model'
require_relative 'model_builder'

if __FILE__ == $0
  mongo_daemon = MongoDaemon.new.start
  Mongoid.load!('./mongoid.yml', :development)
  Mongoid::Config.purge!
  model_builder = ModelBuilder.new.build
  # p AType.all.count
  ANamespace.all.each do |namespace|
    p namespace.unique_name
    p namespace.subnamespaces
    # p namespace.assignements
  end
end
