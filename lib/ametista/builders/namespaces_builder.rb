require_relative 'builder'
require_relative '../utilities'
require_relative '../schema'
require_relative '../queriers/namespaces_querier'

class NamespacesBuilder < Builder

  extend Initializer
  initialize_with ({
    querier: NamespacesQuerier.new
  })

  def build ast
    @ast = ast
    [global_namespace] << namespaces
  end

  def global_namespace
    namespace = Namespace.find_or_create_by(
      unique_name: querier.global_namespace_unique_name
    )
    namespace.contents << content(querier.global_namespace_statements(ast))
    namespace
  end

  # TODO rimuovere il check sui statements quando Postgres consentirà l'inserimento
  # di stringhe vuote per il campo xml
  def content statements
    Content.new({ statements: (statements.empty? ? ' ' : statements) })
  end

  def namespaces
    querier.namespaces(ast).map_unique('id') do |namespace_ast|
      namespace(namespace_ast)
    end
  end

  def namespace namespace_ast
    namespace = Namespace.find_or_create_by(
      unique_name: querier.unique_name(namespace_ast),
    )
    namespace.contents << content(querier.statements(namespace_ast))
    namespace
  end

end

