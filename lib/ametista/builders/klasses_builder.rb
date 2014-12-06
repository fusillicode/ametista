require_relative 'builder'
require_relative '../utilities'
require_relative '../schema'
require_relative '../queriers/klasses_querier'

class KlassesBuilder < Builder

  extend Initializer
  initialize_with ({
    querier: KlassesQuerier.new
  })

  def build ast
    @ast = ast
    klasses
  end

  def klasses
    querier.klasses(ast).map_unique('_id') do |klass_ast|
      Klass.find_or_create_by(
        name: querier.name(klass_ast),
        namespace: namespace(klass_ast),
        parent_klass: parent_klass(klass_ast)
      )
    end
  end

  def namespace klass_ast
    Namespace.find_or_create_by(
      name: querier.namespace_name(klass_ast),
      unique_name: querier.namespace_unique_name(klass_ast),
    )
  end

  def parent_klass klass_ast
    parent_klass_name = querier.parent_klass_name(klass_ast)
    Klass.find_or_create_by(
      name: parent_klass_name,
      unique_name: querier.parent_klass_unique_name(klass_ast),
      # namespace: parent_klass_namespace(klass_ast)
    ) unless parent_klass_name.empty?
  end

  def parent_klass_namespace klass_ast
    Namespace.find_or_create_by(
      name: querier.parent_klass_namespace_name(klass_ast),
      unique_name: querier.parent_klass_namespace_unique_name(klass_ast),
    )
  end

end
