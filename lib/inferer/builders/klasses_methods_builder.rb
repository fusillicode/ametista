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

  def parent ast
    Namespace.find_or_create_by(
      unique_name: querier.parent_unique_name(ast),
      name: querier.parent_name(ast)
    )
  end

  # TODO formalizzare la persistenza dei return_values
  def return_values ast
    querier.return_values(ast).map do |return_value|
      return_value.to_s
    end
  end

end

