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
      KlassMethod.find_or_create_by(
        unique_name: querier.unique_name(klass_method_ast),
        name: querier.name(klass_method_ast),
        klass: klass(klass_method_ast),
        statements: querier.statements(klass_method_ast)
      )
    end
  end

  def klass klass_method_ast
    Klass.find_or_create_by(
      unique_name: querier.klass_unique_name(klass_method_ast),
      name: querier.klass_name(klass_method_ast)
    )
  end

end

