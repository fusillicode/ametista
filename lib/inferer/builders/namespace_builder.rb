require_relative '../utilities'
require_relative '../schema'
require_relative '../queriers/namespace_ast_querier'

class NamespaceBuilder

  extend Initializer
  initialize_with ({
    querier: NamespaceAstQuerier.new,
  })

  def build ast
    @querier.ast = ast
    global_namespace
    namespaces
  end

  def global_namespace
    Namespace.find_or_create_by(
      unique_name: querier.global_namespace_unique_name,
      name: querier.global_namespace_name
    )
  end

  def namespaces
    querier.namespaces.each do |namespace_ast|
      Namespace.find_or_create_by(
        unique_name: querier.namespace_unique_name(namespace_ast),
        name: querier.namespace_name(namespace_ast)

      )
    end
  end

  def klass ast
    scope = querier.scope(ast)
    p Namespace.new
    p Method.new
    exit
    scope.type.find_or_create_by(
      unique_name: scope.unique_name,
      name: scope.name
    )
  end

end

