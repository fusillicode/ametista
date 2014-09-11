require_relative '../utilities'
require_relative '../schema'
require_relative '../queriers/klasses_methods_querier'


class KlassesMethodsBuilder

  extend Initializer
  initialize_with ({
    querier: KlassesMethodsQuerier.new,
  })

  def build ast
    @querier.ast = ast
    klasses_methods
  end

  def klasses_methods
    querier.klasses_methods.each do |klass_method|
      KlassMethod.find_or_create_by(
        unique_name: querier.unique_name(klass_method),
        name: querier.name(klass_method),
        klass: parent(function_ast),
        statements: querier.statements(function_ast)
      )
    end
  end

  def parent ast
    Klass.find_or_create_by(
      unique_name: querier.parent_unique_name(ast),
      name: querier.parent_name(ast)
    )
  end

end

