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
      add_parent_klass(klass(klass_ast), parent_klass(klass_ast))
    end
  end

  def klass klass_ast
    Klass.find_or_create_by(
      name: querier.name(klass_ast),
      namespace: namespace(
        querier.klass_namespaced_name_parts(klass_ast)
      )
    )
  end

  def add_parent_klass klass, parent_klass
    klass.parent_klass = parent_klass
    klass
  end

  def namespace name_parts
    Namespace.find_or_create_by(
      unique_name: querier.namespace_unique_name(name_parts)
    )
  end

  def parent_klass klass_ast
    parent_klass_name = querier.parent_klass_name(klass_ast)
    unless parent_klass_name.empty?
      Klass.find_or_create_by(
        name: parent_klass_name,
        namespace: namespace(
          querier.parent_klass_fully_qualified_name_parts(klass_ast)
        ),
      )
    end
  end

end
