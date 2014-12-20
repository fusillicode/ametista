if __FILE__ == $0
  require 'global'
  require 'active_record'
  Global.environment = 'development'
  Global.config_directory = File.join(Dir.pwd, 'config')
  require_relative '../lib/ametista/builders/model_builder'
  ActiveRecord::Base.establish_connection Global.db.to_hash
  # Per pulire il db
  `rake db:reset`
  # `rake db:drop && rake db:create`
  model_builder = ModelBuilder.new.build
end
