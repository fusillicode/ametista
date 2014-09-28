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
    instances_properties << self_properties << parent_properties << klass_properties
  end

  def instances_properties
    querier.instances_properties(ast).map_unique do |instance_property_ast|
      Property.find_or_create_by(
        name: querier.property_name(instance_property_ast),
        klass: containing_klass(instance_property_ast),
        type: querier.instance_property
      )
    end
  end

  def self_properties
    querier.self_properties(ast).map_unique do |self_property_ast|
      Property.find_or_create_by(
        name: querier.property_name(self_property_ast),
        klass: containing_klass(self_property_ast),
        type: querier.self_property
      )
    end
  end

  def parent_properties
    querier.parent_properties(ast).map_unique do |parent_property_ast|
      Property.find_or_create_by(
        name: querier.property_name(parent_property_ast),
        klass: parent_klass(parent_property_ast),
        type: querier.parent_property
      )
    end
  end

  def klass_properties
    querier.klass_properties(ast).map_unique do |klass_property_ast|
      Property.find_or_create_by(
        name: querier.property_name(klass_property_ast),
        klass: klass(klass_property_ast)
      )
    end
  end

  def containing_klass property_ast
    Klass.find_or_create_by(
      unique_name: querier.containing_klass_unique_name(property_ast),
      name: querier.containing_klass_name(property_ast)
    )
  end

  def parent_klass property_ast
    Klass.find_or_create_by(
      unique_name: querier.parent_klass_unique_name(property_ast),
      name: querier.parent_klass_name(property_ast)
    )
  end

  def klass property_ast
    Klass.find_or_create_by(
      unique_name: querier.klass_unique_name(property_ast),
      name: querier.klass_name(property_ast)
    )
  end

end
