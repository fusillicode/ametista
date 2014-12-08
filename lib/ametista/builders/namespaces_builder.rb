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
    Namespace.find_or_create_by(
      unique_name: querier.global_namespace_unique_name
    ).push(
      statements: querier.global_namespace_statements(ast)
    )
  end

  def namespaces
    querier.namespaces(ast).map_unique('_id') do |namespace_ast|
      namespace(namespace_ast)
    end
  end

  def namespace namespace_ast
    Namespace.find_or_create_by(
      unique_name: querier.unique_name(namespace_ast),
    ).push(
      statements: querier.statements(namespace_ast)
    )
  end

end

