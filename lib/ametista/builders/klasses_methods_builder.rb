require_relative '../utilities'
require_relative '../schema'
require_relative '../queriers/klasses_methods_querier'

class KlassesMethodsBuilder < Builder

  extend Initializer
  initialize_with ({
    querier: KlassesMethodsQuerier.new,
  })

  def build ast
    @ast = ast
    klasses_methods
  end

  def klasses_methods
    querier.klasses_methods(ast).each do |klass_method_ast|
      klass_method(klass_method_ast)
    end
  end

  def klass_method klass_method_ast
    KlassMethod.find_or_create_by(
      name: querier.name(klass_method_ast),
      klass: klass(klass_method_ast),
      statements: querier.statements(klass_method_ast)
    )
  end

  def klass klass_method_ast
    Klass.find_or_create_by(
      name: querier.klass_name(klass_method_ast),
      namespace: namespace(
        querier.klass_namespaced_name_parts(klass_method_ast)
      )
    )
  end

  def namespace name_parts
    Namespace.find_or_create_by(
      unique_name: querier.namespace_unique_name(name_parts)
    )
  end

end

