require_relative '../utilities'
require_relative '../schema'
require_relative '../queriers/namespaces_ast_querier'
require_relative 'builder'

class NamespacesBuilder < Builder

  extend Initializer
  initialize_with ({
    querier: NamespacesAstQuerier.new,
  })

  def build ast
    @querier.ast = ast
    namespaces
  end

  def namespaces
    global_namespace + other_namespaces
  end

  def global_namespace
    [ Namespace.find_or_create_by(
      unique_name: querier.global_namespace_unique_name,
      name: querier.global_namespace_name
    ) ]
  end

  def other_namespaces
    querier.namespaces.map_unique do |namespace_ast|
      Namespace.find_or_create_by(
        unique_name: querier.unique_name(namespace_ast),
        name: querier.name(namespace_ast)
      )
    end
  end

end

