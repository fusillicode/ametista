require_relative '../schema'
require_relative 'analyzer'
require_relative '../queriers/usage_querier'

class UsageAnalyzer < Analyzer

  extend Initializer
  initialize_with ({
    querier: UsageQuerier.new
  })

  def analyze
    analyze_namespaces_statements
  end

  def analyze_namespaces_statements
    Klass.each do |element|
      ap element
      ap element.namespace.unique_name
      # exit
      # querier.methods_calls().each do |method_call|
      # end
    end
  end

  def analyze_functions_statements

  end

  def analyze_methods_statements

  end

end
