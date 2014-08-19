require_relative '../utilities'
require_relative '../schema'
require_relative '../queriers/a_function_ast_querier'

class AFunctionBuilder

  extend Initializer
  initialize_with ({
    querier: AFunctionAstQuerier.new
  })

  def build ast
    @querier.ast = ast
    global_namespace
    functions
  end

  def functions
    querier.functions.each do |function_ast|
      function = AFunction.find_or_create_by(
        unique_name: querier.unique_name(function_ast),
        name: querier.name(function_ast),
        namespace: namespace,
        return_values:
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
    ANamespace.find_or_create_by(
      unique_name: querier.namespace_unique_name
      name: querier.namespace_name
    )
  end

end
