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
    querier.functions(ast).map_unique('id') do |function_ast|
      function(function_ast)
    end
  end

  def function function_ast
    Function.find_or_create_by(
      name: querier.name(function_ast),
      namespace: namespace(
        querier.procedure_namespaced_name_parts(function_ast)
      )
    ).tap { |o| o.contents << content(querier.statements(function_ast)) }
  end

end
