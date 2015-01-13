require_relative '../schema'
require_relative 'rule'
require_relative '../queriers/primitive_types_assignements_querier'

class PrimitiveTypesAssignements < Rule

  extend Initializer
  initialize_with ({
    querier: PrimitiveTypesAssignementsQuerier.new
  })

  def apply
    apply_on_functions_statements # << apply_on_namespaces_statements << apply_on_klasses_methods_statements
  end

  def apply_on_namespaces_statements
  end

  def apply_on_functions_statements
    Function.all.each do |function|
      ap function.namespace
      querier.xpath('.//Expr_Assign', function.contents.first.statements).each do |res|
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

  def apply_on_klasses_methods_statements
  end

end
