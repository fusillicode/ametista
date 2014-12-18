if __FILE__ == $0
  require 'global'
  require 'active_record'
  require_relative '../lib/ametista/builders/model_builder'
  Global.environment = 'development'
  Global.config_directory = File.join(Dir.pwd, 'config')
  ActiveRecord::Base.establish_connection Global.db.to_hash
  # Per pulire il db
  `rake db:reset`
  model_builder = ModelBuilder.new.build
end
