require_relative 'builder'
require_relative '../utilities'
require_relative '../schema'
require_relative '../queriers/properties_querier'
require_relative 'klasses_methods_builder'

# TODO per il building delle proprietà delle istanze ho sempre bisogno di
# costruire prima la gerarchia di ereditarietà delle classi!!!
# Forse conviene tenere le proprietà delle istanze separate dal resto...

class PropertiesBuilder < Builder

  extend Initializer
  initialize_with ({
    querier: PropertiesQuerier.new,
    klasses_builder: KlassesBuilder.new
  })

  def build ast
    @ast = ast
    instances_properties << self_properties << parent_properties << klass_properties
  end

  def instances_properties
    querier.instances_properties(ast).map_unique('_id') do |instance_property_ast|
      Property.find_or_create_by(
        name: querier.name(instance_property_ast),
        klass: klasses_builder.klass(
          querier.klass(instance_property_ast)
        ),
        type: querier.instance_property
      )
    end
  end

  def self_properties
    querier.self_properties(ast).map_unique('_id') do |self_property_ast|
      Property.find_or_create_by(
        name: querier.name(self_property_ast),
        klass: klasses_builder.klass(
          querier.klass(self_property_ast)
        ),
        type: querier.self_property
      )
    end
  end

  def parent_properties
    querier.parent_properties(ast).map_unique('_id') do |parent_property_ast|
      Property.find_or_create_by(
        name: querier.name(parent_property_ast),
        klass: klasses_builder.parent_klass(
          querier.klass(parent_property_ast)
        ),
        type: querier.parent_property
      )
    end
  end

  def klass_properties
    querier.klass_properties(ast).map_unique('_id') do |klass_property_ast|
      Property.find_or_create_by(
        name: querier.name(klass_property_ast),
        klass: klass(klass_property_ast)
      )
    end
  end

  # Non posso usare KlassesBuilder.klass al posto di questo metodo perchè il namespace
  # viene costruito diversamente nei due casi...
  def klass klass_property_ast
    Klass.find_or_create_by(
      name: querier.klass_name(klass_property_ast),
      namespace: klasses_builder.namespace(
        querier.klass_fully_qualified_name_parts(klass_property_ast)
      )
    )
  end

end
