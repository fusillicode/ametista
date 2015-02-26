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
    querier.klasses(ast).map_unique('id') do |klass_ast|
      klass(klass_ast)
    end
  end

  def klass klass_ast
    Klass.find_or_create_by(
      name: querier.name(klass_ast),
      namespace: namespace(
        querier.procedure_namespaced_name_parts(klass_ast)
      ),
      parent: parent_klass(klass_ast)
    )
  end

  def parent_klass klass_ast
    parent_klass_name = querier.parent_klass_name(klass_ast)
    unless parent_klass_name.empty?
      Klass.find_or_create_by(
        name: parent_klass_name,
        namespace: namespace(
          querier.parent_klass_fully_qualified_name_parts(klass_ast)
        )
      )
    end
  end

end
