require_relative 'builder'
require_relative '../utilities'
require_relative '../schema'
require_relative '../queriers/custom_types_querier'
require_relative 'klasses_builder'

class CustomTypesBuilder < Builder

  extend Initializer
  initialize_with ({
    querier: CustomTypesQuerier.new,
    klasses_builder: KlassesBuilder.new
  })

  def build ast
    @ast = ast
    custom_types
  end

  def custom_types
    parameters_custom_types << klasses_builder.build(ast)
  end

  def parameters_custom_types
    querier.parameters_custom_types(ast).map_unique('id') do |parameter_custom_type_ast|
      custom_type(parameter_custom_type_ast)
    end
  end

  def custom_type custom_type_ast
    CustomType.find_or_create_by(
      name: querier.name(custom_type_ast),
      namespace: namespace(
        querier.name_parts(custom_type_ast)
      )
    )
  end

  def namespace name_parts
    Namespace.find_or_create_by(
      unique_name: querier.namespace_unique_name(name_parts),
    )
  end

end
