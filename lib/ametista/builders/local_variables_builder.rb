require_relative 'builder'
require_relative '../utilities'
require_relative '../schema'
require_relative '../queriers/local_variables_querier'
require_relative 'namespaces_builder'
require_relative 'functions_builder'
require_relative 'klasses_methods_builder'
require_relative 'versions_builder'

class LocalVariablesBuilder < Builder

  extend Initializer
  initialize_with ({
    querier: LocalVariablesQuerier.new,
    namespaces_builder: NamespacesBuilder.new,
    functions_builder: FunctionsBuilder.new,
    klasses_methods_builder: KlassesMethodsBuilder.new,
    version_builder: VersionsBuilder.new
  })

  def build ast
    @ast = ast
    local_variables
  end

  def local_variables
    namespaces_local_variables  # << functions_local_variables << klasses_methods_local_variables
  end

  # TODO vedere di ristrutturare il building delle variabili locali (come anche dei parametri) tirando fuori prima i loro parent evitando così di fare troppe query xpath relative ai parent (i.e. funzioni e metodi di classe).

  def namespaces_local_variables
    querier.namespaces_local_variables(ast).map_unique('id') do |namespace_local_variable_ast|
      LocalVariable.find_or_create_by(
        name: querier.namespace_local_variable_name(namespace_local_variable_ast),
        scope: namespaces_builder.namespace(namespace_local_variable_ast)
      ).tap { |o| version_builder.version(o, namespace_local_variable_ast) }
    end
  end

  def functions_local_variables
    querier.functions_local_variables(ast).map_unique('id') do |function_local_variable_ast|
      LocalVariable.find_or_create_by(
        name: querier.name(function_local_variable_ast),
        scope: functions_builder.function(
          querier.function(function_local_variable_ast)
        )
      ).tap { |o| version_builder.version(o, function_local_variable_ast) }
    end
  end

  def klasses_methods_local_variables
    querier.klasses_methods_local_variables(ast).map_unique('id') do |klass_method_local_variable_ast|
      LocalVariable.find_or_create_by(
        name: querier.name(klass_method_local_variable_ast),
        scope: klasses_methods_builder.klass_method(
          querier.klass_method(klass_method_local_variable_ast)
        )
      ).tap { |o| version_builder.version(o, klass_method_local_variable_ast) }
    end
  end

end
