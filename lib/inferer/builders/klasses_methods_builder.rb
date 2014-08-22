require_relative '../utilities'
require_relative '../schema'
require_relative '../queriers/klasses_methods_ast_querier'


class KlassesMethodsBuilder

  extend Initializer
  initialize_with ({
    querier: KlassesMethodsAstQuerier.new,
  })

  def build ast
    @querier.ast = ast
    klasses_methods
  end

  def klasses_methods
    querier.klasses_methods.each do |klass_method|
      KlassMethod.find_or_create_by(
        unique_name: querier.unique_name(klass_method),
        name: querier.name(klass_method)
      )
    end
  end

end

