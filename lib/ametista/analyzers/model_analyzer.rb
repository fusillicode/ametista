# TODO come posso sistemare tutti questi require_relative?
require_relative '../utilities'
require_relative 'usage_analyzer'

class ModelAnalyzer

  extend Initializer
  initialize_with ({
    analyzers: {
      usage_analyzer: UsageAnalyzer.new
    }
  })

  def analyze
    analyzers.each do |key, analyzer|
      analyzer.analyze
    end
  end
end
