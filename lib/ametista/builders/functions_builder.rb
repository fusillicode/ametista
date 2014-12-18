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
        querier.function_namespaced_name_parts(function_ast)
      )
    )
    function.contents << content(querier.statements(function_ast))
    function
  end

  # TODO rimuovere il check sui statements quando Postgres consentirà l'inserimento
  # di stringhe vuote per il campo xml
  def content statements
    Content.new({ statements: (statements.empty? ? ' ' : statements) })
  end

  def namespace name_parts
    Namespace.find_or_create_by(
      unique_name: querier.namespace_unique_name(name_parts)
    )
  end

end
