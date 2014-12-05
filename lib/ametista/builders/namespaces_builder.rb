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
    global_namespace << namespaces
  end

  def global_namespace
    namespace = Namespace.find_or_create_by(
      unique_name: querier.global_namespace_unique_name,
      name: querier.global_namespace_name
    )
    namespace.push statements: querier.global_namespace_statements(ast)
    [ namespace ]
  end

  def namespaces
    querier.namespaces(ast).map_unique('_id') do |namespace_ast|
      namespace = Namespace.find_or_create_by(
        unique_name: querier.unique_name(namespace_ast),
        name: querier.name(namespace_ast)
      )
      namespace.push statements: querier.statements(namespace_ast)
      namespace
    end
  end
end

