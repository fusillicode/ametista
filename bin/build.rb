if __FILE__ == $0
  require 'active_record'
  require 'yaml'
  require_relative '../lib/ametista/builders/model_builder'
  model_builder = ModelBuilder.new.build
end
