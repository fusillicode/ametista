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
    function = Function.find_or_create_by(
      name: querier.name(function_ast),
      namespace: namespace(
        querier.procedure_namespaced_name_parts(function_ast)
      )
    )
    function.contents << content(querier.statements(function_ast))
    function
  end

  # Qui non posso usare il NamespacesBuilder passando l'ast del parent della funzione
  # perchè la funzione potrebbe essere definita in un namespace diverso tramite PHP use
  def namespace name_parts
    Namespace.find_or_create_by(
      name: querier.namespace_name(name_parts)
    )
  end

end
