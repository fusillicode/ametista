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
    Function.all.each do |function|
      ap function.namespace
      ActiveRecord::Base.connection.execute("select unnest(xpath('.//Expr_Assign', '#{function.contents.first.statements}'))").each do |res|
        ap res
      end
      exit
    end
    # Function.each do |function|
    #   ap function.statements
    #   function.statements.find({  }).each do |a|
    #     ap a
    #   end
    #   exit
    #   # querier.methods_calls(parser.parse(function.statements)).each do |method_call|
    #   #   p method_call
    #   # end
    # end
  end

  def analyze_methods_statements

  end

end
