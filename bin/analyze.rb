if __FILE__ == $0
  require 'global'
  require 'active_record'
  Global.environment = 'development'
  Global.config_directory = File.join(Dir.pwd, 'config')
  ActiveRecord::Base.establish_connection Global.db.to_hash
  require_relative '../lib/ametista/analyzers/model_analyzer'
  model_analyzer = ModelAnalyzer.new.analyze
end
