require_relative 'builder'
require_relative '../utilities'
require_relative '../queriers/querier'

class PrimitiveTypesBuilder < Builder

  def build
    primitive_types
  end

  def primitive_types
    querier.primitive_types.map_unique do |primitive_type|
      PrimitiveType.create(
        unique_name: primitive_type,
        name: primitive_type
      )
    end
  end

end
