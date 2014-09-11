require_relative 'builder'
require_relative '../utilities'
require_relative '../schema'
require_relative '../queriers/custom_types_querier'

class CustomTypesBuilder < Builder

  extend Initializer
  initialize_with ({
    querier: CustomTypesQuerier.new
  })

  def build ast
    @ast = ast
    custom_types
  end

  def custom_types
    querier.custom_types(ast).map_unique do |custom_type_ast|
      CustomType.find_or_create_by(
        unique_name: querier.unique_name(custom_type_ast),
        name: querier.name(custom_type_ast)
      )
    end
  end

end
