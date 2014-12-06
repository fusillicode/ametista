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
    parameters_custom_types << klasses_custom_types
  end

  def parameters_custom_types
    querier.parameters_custom_types(ast).map_unique('_id') do |parameter_custom_type|
      CustomType.find_or_create_by(
        name: querier.parameter_custom_type_name(parameter_custom_type),
        namespace: namespace(parameter_custom_type)
      )
    end
  end

  def klasses_custom_types
    querier.klasses_custom_types(ast).map_unique('_id') do |klass_custom_type_ast|
      CustomType.find_or_create_by(
        name: querier.klass_custom_type_name(klass_custom_type_ast),
        namespace: namespace(klass_custom_type_ast)
      )
    end
  end

  # TODO qui bisogna sistemare il namespace che deve essere quello dedotto dal fully qualified name
  def namespace ast
    Namespace.find_or_create_by(
      unique_name: querier.namespace_unique_name(ast),
    )
  end

end
