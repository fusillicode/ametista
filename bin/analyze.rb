if __FILE__ == $0
  require 'mongoid'
  require_relative '../lib/ametista/analyzers/model_analyzer'
  Mongoid.load!('./mongoid.yml', :development)
  model_analyzer = ModelAnalyzer.new.analyze
end
