require_relative 'builder'
require_relative '../utilities'
require_relative '../schema'
require_relative '../queriers/functions_querier'

class FunctionsBuilder < Builder

  extend Initializer
  initialize_with ({
    querier: FunctionsQuerier.new
  })

  def build ast
    @ast = ast
    functions
  end

  def functions
    querier.functions(ast).map_unique do |function_ast|
      Function.find_or_create_by(
        unique_name: querier.unique_name(function_ast),
        name: querier.name(function_ast),
        namespace: namespace(function_ast),
        statements: querier.statements(function_ast)
      )
    end
  end

  def namespace function_ast
    Namespace.find_or_create_by(
      unique_name: querier.namespace_unique_name(ast),
      name: querier.namespace_name(ast)
    )
  end

end
