require_relative 'builder'
require_relative '../utilities'
require_relative '../schema'
require_relative '../queriers/global_variables_querier'
require_relative 'versions_builder'

class GlobalVariablesBuilder < Builder

  extend Initializer
  initialize_with ({
    querier: GlobalVariablesQuerier.new,
    version_builder: VersionsBuilder.new
  })

  def build ast
    @ast = ast
    global_variables
  end

  def global_variables
    global_namespace_variables << global_definitions << superglobals
  end

  def global_namespace_variables
    querier.global_namespace_variables(ast).map_unique('id') do |global_namespace_variable_ast|
      global_variable = GlobalVariable.find_or_create_by(
        name: querier.name(global_namespace_variable_ast),
      )
      version_builder.version(
        global_variable,
        global_namespace_variable_ast
      )
      global_variable
    end
  end

  def global_definitions
    querier.global_definitions(ast).map_unique('id') do |global_definition_ast|
      global_variable = GlobalVariable.find_or_create_by(
        name: querier.name(global_definition_ast)
      )
      version_builder.version(
        global_variable,
        global_definition_ast
      )
      global_variable
    end
  end

  def superglobals
    querier.superglobals(ast).map_unique('id') do |superglobal_ast|
      global_variable = GlobalVariable.find_or_create_by(
        name: querier.superglobal_name(superglobal_ast),
        kind: querier.superglobal_type(superglobal_ast)
      )
      version_builder.version(
        global_variable,
        superglobal_ast
      )
      global_variable
    end
  end

end
