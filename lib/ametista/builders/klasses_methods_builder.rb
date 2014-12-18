require_relative '../utilities'
require_relative '../schema'
require_relative '../queriers/klasses_methods_querier'
require_relative 'klasses_builder.rb'

class KlassesMethodsBuilder < Builder

  extend Initializer
  initialize_with ({
    querier: KlassesMethodsQuerier.new,
    klasses_builder: KlassesBuilder.new
  })

  def build ast
    @ast = ast
    klasses_methods
  end

  def klasses_methods
    querier.klasses_methods(ast).map_unique('id') do |klass_method_ast|
      klass_method(klass_method_ast)
    end
  end

  def klass_method klass_method_ast
    klass_method = KlassMethod.find_or_create_by(
      name: querier.name(klass_method_ast),
      klass: klasses_builder.klass(
        querier.klass(klass_method_ast)
      )
    )
    klass_method.contents << content(querier.statements(klass_method_ast))
    klass_method
  end

end

