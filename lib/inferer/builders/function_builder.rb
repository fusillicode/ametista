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
      function = Function.find_or_create_by(
        unique_name: querier.unique_name(function_ast),
        name: querier.name(function_ast),
        namespace: namespace,
        return_values: 'asd'
      )
    end
  end

  def namespace
    Namespace.find_or_create_by(
      unique_name: querier.namespace_unique_name,
      name: querier.namespace_name
    )
  end

  def return_values

  end

end
