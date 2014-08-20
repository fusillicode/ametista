# TODO come posso sistemare tutti questi require_relative?
require_relative '../utilities'
require_relative '../redis_data_source'
require_relative '../xml_parser'
require_relative 'language_builder'
require_relative 'namespace_builder'
require_relative 'function_builder'
require_relative 'custom_type_builder'
require_relative 'klass_builder'
require_relative 'kmethod_builder'
require_relative 'branch_builder'
require_relative 'assignement_builder'

class ModelBuilder

  extend Initializer
  initialize_with ({
    parser: XMLParser.new,
    data_source: RedisDataSource.new,
    language_builder: LanguageBuilder.new,
    namespaces_builder: NamespaceBuilder.new,
    functions_builder: FunctionBuilder.new,
    custom_types_builder: CustomTypeBuilder.new,
    classes_builder: KlassBuilder.new,
    methods_builder: KMethodBuilder.new,
    branches_builder: BranchBuilder.new,
    assignements_builder: AssignementBuilder.new
  })

  def build
    init_build
    start_building_loop
  end

  def init_build
    language_builder.build
  end

  def start_building_loop
    while ast = data_source.read
      # TODO togliere il break e la condizione una volta sistemato data_source.read
      break if ast == "THAT'S ALL FOLKS!"
      ast = parser.parse(ast)
      namespaces_builder.build(ast)
      functions_builder.build(ast)
      p custom_types_builder.build(ast)
      # parameters_builder.build(ast)
      # global_variables_builder.build(ast)
      # local_variables_builder.build(ast)
      # properties_variables_builder.build(ast)
      # klasses_builder.build(ast)
      # kmethods_builder.build(ast)
      # branches_builder.build(ast)
      # assignements_builder.build(ast)
    end
  end

end
