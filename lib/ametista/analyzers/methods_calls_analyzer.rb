require_relative '../schema'
require_relative 'analyzer'
require_relative '../queriers/methods_calls_querier'

class MethodsCallsAnalyzer < Analyzer

  extend Initializer
  initialize_with ({
    querier: MethodsCallsQuerier.new
  })

  def analyze
    analyze_functions_statements
  end

  def analyze_namespaces_statements

  end

  def analyze_functions_statements
    # Function.each do |function|
    #   querier.methods_calls(function.statements).each do |method_call|

    #   end
    # end
  end

  def analyze_methods_statements

  end

end
