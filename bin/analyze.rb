if __FILE__ == $0
  require 'active_record'
  require 'yaml'
  require_relative '../lib/ametista/analyzers/model_analyzer'
  model_analyzer = ModelAnalyzer.new.analyze
end
