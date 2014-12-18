# TODO come posso sistemare tutti questi require_relative?
require 'awesome_print'
require_relative '../utilities'
require_relative '../redis_channel'
require_relative '../xml_parser'
require_relative '../refiners/instances_properties_refiner'
require_relative 'primitive_types_builder'
require_relative 'namespaces_builder'
require_relative 'functions_builder'
require_relative 'custom_types_builder'
require_relative 'parameters_builder'
require_relative 'global_variables_builder'
require_relative 'local_variables_builder'
require_relative 'properties_builder'
require_relative 'klasses_builder'
require_relative 'klasses_methods_builder'

class ModelBuilder

  extend Initializer
  initialize_with ({
    parser: XMLParser.new,
    channel: RedisChannel.new,
    init_builders: {
      primitive_types_builder: PrimitiveTypesBuilder.new
    },
    builders: {
      namespaces_builder: NamespacesBuilder.new,
      functions_builder: FunctionsBuilder.new,
      klasses_builder: KlassesBuilder.new,
      klasses_methods_builder: KlassesMethodsBuilder.new,
      custom_types_builder: CustomTypesBuilder.new,
      parameters_builder: ParametersBuilder.new,
      global_variables_builder: GlobalVariablesBuilder.new,
      local_variables_builder: LocalVariablesBuilder.new,
      properties_builder: PropertiesBuilder.new
    },
    refiners: {
      instances_properties_refiner: InstancesPropertiesRefiner.new
    }
  })

  def build
    init_build
    building_loop
    refine_model
    test
  end

  def test
    Property.instances_properties.each do |element|
      ap element.unique_name
    end
  end

  def init_build
    init_builders.each do |key, init_builder|
      init_builder.build
    end
  end

  def building_loop
    while ast = channel.read
      builders_loop(parser.parse(ast))
    end
  end

  def refine_model
    refiners.each do |key, refiner|
      refiner.refine
    end
  end

  def builders_loop ast
    builders.each do |key, builder|
      ap "#{builder.class} loop"
      builder.build(ast)
    end
  end

end
