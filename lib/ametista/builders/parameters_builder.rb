require_relative 'builder'
require_relative '../utilities'
require_relative '../schema'
require_relative '../queriers/parameters_querier'
require_relative 'functions_builder'
require_relative 'klasses_methods_builder'

class ParametersBuilder < Builder

  extend Initializer
  initialize_with ({
    querier: ParametersQuerier.new,
    functions_builder: FunctionsBuilder.new,
    klasses_methods_builder: KlassesMethodsBuilder.new
  })

  def build ast
    @ast = ast
    parameters
  end

  def parameters
    functions_parameters | klasses_methods_parameters
  end

  def functions_parameters
    querier.functions_parameters(ast).map_unique('id') do |function_parameter_ast|
      Parameter.find_or_create_by(
        name: querier.name(function_parameter_ast),
        procedure: functions_builder.function(
          querier.function(function_parameter_ast)
        )
      )
    end
  end

  def klasses_methods_parameters
    querier.klasses_methods_parameters(ast).map_unique('id') do |klass_method_parameter_ast|
      Parameter.find_or_create_by(
        name: querier.name(klass_method_parameter_ast),
        procedure: klasses_methods_builder.klass_method(
          querier.klass_method(klass_method_parameter_ast)
        )
      )
    end
  end

end
