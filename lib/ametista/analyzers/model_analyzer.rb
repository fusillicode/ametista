# TODO come posso sistemare tutti questi require_relative?
require 'awesome_print'
require_relative '../utilities'
require_relative 'methods_calls_analyzer'

class ModelAnalyzer

  extend Initializer
  initialize_with ({
    analyzers: {
      methods_calls_analyzer: MethodsCallsAnalyzer.new
    }
  })

  def analyze
    analyzers.each do |key, analyzer|
      analyzer.analyze
    end
  end
end
