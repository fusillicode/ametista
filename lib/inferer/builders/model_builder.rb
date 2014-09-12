# TODO come posso sistemare tutti questi require_relative?
require_relative '../utilities'
require_relative '../redis_data_source'
require_relative '../xml_parser'
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
    data_source: RedisDataSource.new,
    init_builders: {
      primitive_types_builder: PrimitiveTypesBuilder.new
    },
    builders: {
      # namespaces_builder: NamespacesBuilder.new,
      # functions_builder: FunctionsBuilder.new,
      # custom_types_builder: CustomTypesBuilder.new,
      # parameters_builder: ParametersBuilder.new,
      # global_variables_builder: GlobalVariablesBuilder.new,
      # local_variables_builder: LocalVariablesBuilder.new,
      # properties_builder: PropertiesBuilder.new,
      # klasses_builder: KlassesBuilder.new,
      # klasses_methods_builder: KlassesMethodsBuilder.new
    }
  })

  def build
    init_build
    building_loop
  end

  def init_build
    init_builders.each do |key, init_builder|
      init_builder.build
    end
  end

  def builders_loop ast
    builders.each do |key, builder|
      builder.build(ast)
    end
  end

  def building_loop
    while ast = data_source.read
      # TODO togliere il break e la condizione una volta sistemato data_source.read
      break if ast == "THAT'S ALL FOLKS!"
      builders_loop(parser.parse(ast))
    end
    # PrimitiveType.all.each do |entity|
    #   p "#{entity.name} #{entity.unique_name}"
    # end
  end

end
