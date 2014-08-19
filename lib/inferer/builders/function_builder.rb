require_relative '../utilities'
require_relative '../schema'
require_relative '../queriers/function_ast_querier'

class FunctionBuilder

  extend Initializer
  initialize_with ({
    querier: FunctionAstQuerier.new
  })

  def build ast
    @querier.ast = ast
    functions
  end

  def functions
    querier.functions.map do |function_ast|
      Function.find_or_create_by(
        unique_name: querier.unique_name(function_ast),
        name: querier.name(function_ast),
        namespace: namespace(function_ast),
        return_values: ['asd']
      )
    end
  end

  def namespace ast
    Namespace.find_or_create_by(
      unique_name: querier.parent_unique_name(ast),
      name: querier.parent_name(ast)
    )
  end

  def return_values

  end

end
