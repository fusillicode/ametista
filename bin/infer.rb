if __FILE__ == $0
  require 'global'
  require 'active_record'
  Global.environment = 'development'
  Global.config_directory = File.join Dir.pwd, 'config'
  ActiveRecord::Base.establish_connection Global.db.to_hash
  require_relative '../lib/ametista/rules/inference_engine'
  model_analyzer = InferenceEngine.new.infer
end
