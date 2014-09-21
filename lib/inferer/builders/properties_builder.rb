require_relative 'builder'
require_relative '../utilities'
require_relative '../schema'
require_relative '../queriers/properties_querier'

class PropertiesBuilder < Builder

  extend Initializer
  initialize_with ({
    querier: PropertiesQuerier.new
  })

  def build ast
    @ast = ast
    static_properties
  end

  def properties
    querier.properties(ast).map_unique do |property_ast|
      Property.find_or_create_by(
        unique_name: querier.unique_name(property_ast),
        name: querier.name(property_ast),
        statements: querier.statements(property_ast)
      )
    end
  end

  def klass property_ast
    Klass.find_or_create_by(
      unique_name: querier.klass_unique_name(property_ast),
      name: querier.klass_name(property_ast)
    )
  end

end

