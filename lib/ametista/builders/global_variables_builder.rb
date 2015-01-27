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
    global_namespace_variables << global_definitions << superglobals << defined_constants << klass_constants
  end

  def global_namespace_variables
    querier.global_namespace_variables(ast).map_unique('id') do |global_namespace_variable_ast|
      GlobalVariable.find_or_create_by(
        name: querier.name(global_namespace_variable_ast),
      ).tap { |o| version_builder.version(o, global_namespace_variable_ast) }
    end
  end

  def global_definitions
    querier.global_definitions(ast).map_unique('id') do |global_definition_ast|
      GlobalVariable.find_or_create_by(
        name: querier.name(global_definition_ast)
      ).tap { |o| version_builder.global_definition_versions(o, global_definition_ast) }
    end
  end

  def superglobals
    querier.superglobals(ast).map_unique('id') do |superglobal_ast|
      GlobalVariable.find_or_create_by(
        name: querier.superglobal_name(superglobal_ast),
        kind: querier.superglobal_type(superglobal_ast)
      ).tap { |o| version_builder.version(o, superglobal_ast) }
    end
  end

  def defined_constants
    querier.defined_constants(ast).map_unique('id') do |defined_constant_ast|
      GlobalVariable.find_or_create_by(
        name: querier.defined_constant_name(defined_constant_ast),
        kind: 'CONSTANT'
      ).tap { |o| version_builder.defined_constant_version(o, defined_constant_ast) }
    end
  end

  def klass_constants

  end

end
