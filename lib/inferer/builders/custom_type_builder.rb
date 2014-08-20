require_relative '../utilities'
require_relative '../schema'
require_relative '../queriers/custom_type_ast_querier'

class CustomTypeBuilder

  extend Initializer
  initialize_with ({
    querier: CustomTypeAstQuerier.new
  })

  def build ast
    @querier.ast = ast
    custom_types
  end

  def custom_types
    # TODO attenzione che usando find_or_create_by e map si ottengono degli array
    # con degli oggetti potenzialmente duplicati
    querier.custom_types.map_unique do |custom_type_ast|
      CustomType.find_or_create_by(
        unique_name: querier.unique_name(custom_type_ast),
        name: querier.name(custom_type_ast)
      )
    end
  end

end
