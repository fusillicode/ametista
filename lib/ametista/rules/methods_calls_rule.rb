require_relative '../schema'
require_relative 'rule'

class MethodsCallsRule < Rule

  extend Initializer
  initialize_with ({

  })

  def apply
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
