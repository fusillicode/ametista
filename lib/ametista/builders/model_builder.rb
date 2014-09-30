# TODO come posso sistemare tutti questi require_relative?
require_relative '../utilities'
require_relative '../redis_data_source'
require_relative '../xml_parser'
require_relative '../instances_properties_refiner'
require_relative 'language_builder'
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
include PatchedAwesomePrint

class ModelBuilder

  extend Initializer
  initialize_with ({
    parser: XMLParser.new,
    data_source: RedisDataSource.new,
    init_builders: {
      language_builder: LanguageBuilder.new,
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
    just_tests
  end

  def init_build
    init_builders.each do |key, init_builder|
      init_builder.build
    end
  end

  def building_loop
    while ast = data_source.read
      builders_loop(parser.parse(ast))
    end
  end

  def refine_model
    refiners.each do |key, refiner|
      refiner.refine
    end
  end

  def just_tests
    Parameter.each do |entity|
      ap "#{entity.name} #{entity.klass.name}"
      ap "#{entity.unique_name} #{entity.klass.unique_name}"
    end
  end

  def builders_loop ast
    builders.each do |key, builder|
      builder.build(ast)
    end
  end

end
