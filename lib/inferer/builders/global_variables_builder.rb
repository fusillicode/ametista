require_relative 'builder'
require_relative '../utilities'
require_relative '../schema'
require_relative '../queriers/global_variables_querier'

class GlobalVariablesBuilder < Builder

  extend Initializer
  initialize_with ({
    querier: GlobalVariablesQuerier.new
  })

  def build ast
    @ast = ast
    global_variables
  end

  def global_variables
    global_namespace_variables << global_definitions << superglobals
  end

  def global_namespace_variables
    querier.global_namespace_variables(ast).map_unique do |global_namespace_variable_ast|
      GlobalVariable.find_or_create_by(
        unique_name: querier.global_namespace_variable_unique_name(global_namespace_variable_ast),
        name: querier.global_namespace_variable_name(global_namespace_variable_ast)
      )
    end
  end

  def global_definitions
    querier.global_definitions(ast).map_unique do |global_definition_ast|
      GlobalVariable.find_or_create_by(
        unique_name: querier.global_definition_unique_name(global_definition_ast),
        name: querier.global_definition_name(global_definition_ast)
      )
    end
  end

  def superglobals
    querier.superglobals(ast).map_unique do |superglobal_ast|
      Superglobal.find_or_create_by(
        unique_name: querier.superglobal_unique_name(superglobal_ast),
        name: querier.superglobal_name(superglobal_ast),
        type: querier.superglobal_type(superglobal_ast)
      )
    end
  end

end
