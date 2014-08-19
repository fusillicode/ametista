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
    global_namespace
    functions
  end

  def functions
    querier.functions.each do |function_ast|
      function = Function.find_or_create_by(
        unique_name: querier.unique_name(function_ast),
        name: querier.name(function_ast),
        namespace: namespace,
        return_values: 'asd'
      )
      function.parameters = parameters(function_ast)
    end
  end

  def parameters ast
    querier.functions
  end

  def return_values

  end

  def namespace
    Namespace.find_or_create_by(
      unique_name: querier.namespace_unique_name,
      name: querier.namespace_name
    )
  end

end
