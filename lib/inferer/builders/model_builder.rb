# TODO come posso sistemare tutti questi require_relative?
require_relative '../utilities'
require_relative '../redis_data_source'
require_relative 'language_builder'
require_relative 'a_namespace_builder'
require_relative 'a_function_builder'
require_relative 'a_class_builder'
require_relative 'a_method_builder'
require_relative 'a_branch_builder'
require_relative 'an_assignement_builder'

class ModelBuilder

  extend Initializer
  initialize_with ({
    parser: XMLParser.new,
    data_source: RedisDataSource.new,
    language_builder: LanguageBuilder.new,
    namespaces_builder: ANamespaceBuilder.new,
    functions_builder: AFunctionBuilder.new,
    classes_builder: AClassBuilder.new,
    methods_builder: AMethodBuilder.new,
    branches_builder: ABranchBuilder.new,
    assignements_builder: AnAssignementBuilder.new
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
      # functions_builder.build(ast)
      # classes_builder.build(ast)
      # methods_builder.build(ast)
      # branches_builder.build(ast)
      assignements_builder.build(ast)
    end
  end

end
