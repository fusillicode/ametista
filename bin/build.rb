if __FILE__ == $0
  require 'active_record'
  require 'yaml'
  config_file = File.join Dir.pwd, 'db', 'config.yml'
  ENV['DB'] = 'development'
  config = YAML::load(File.open config_file)
  ActiveRecord::Base.establish_connection config[ENV['DB']]
  # model_builder = ModelBuilder.new.build
end
