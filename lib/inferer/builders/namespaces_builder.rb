require_relative '../utilities'
require_relative '../schema'
require_relative '../queriers/namespaces_ast_querier'


class NamespacesBuilder

  extend Initializer
  initialize_with ({
    querier: NamespacesAstQuerier.new,
    ast: nil
  })

  def build ast
    @ast = ast
    namespaces
  end

  def namespaces
    querier.namespaces(ast).map_unique do |namespace_ast|
      Namespace.find_or_create_by(
        unique_name: querier.unique_name(namespace_ast),
        name: querier.name(namespace_ast)
      )
    end
  end

end

