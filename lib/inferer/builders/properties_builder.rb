require_relative 'builder'
require_relative '../utilities'
require_relative '../schema'
require_relative '../queriers/properties_querier'

# TODO per il building delle proprietà delle istanze ho sempre bisogno di
# costruire prima la gerarchia di ereditarietà delle classi!!!
# Forse conviene tenere le proprietà delle istanze separate dal resto...

class PropertiesBuilder < Builder

  extend Initializer
  initialize_with ({
    querier: PropertiesQuerier.new
  })

  def build ast
    @ast = ast
    instances_properties
  end

  def instance_properties
    querier.instance_properties(ast).map_unique do |instance_property_ast|
      Property.find_or_create_by(
        unique_name: querier.unique_name(instance_property_ast),
        name: querier.name(instance_property_ast),
        klass: klass(instance_property_ast)
      )
    end
  end

  def klass instance_property_ast
    klass = Klass.find_or_create_by(
      unique_name: querier.klass_unique_name(instance_property_ast),
      name: querier.klass_name(instance_property_ast)
    )
    return klass unless klass.parent_klass

  end

end

