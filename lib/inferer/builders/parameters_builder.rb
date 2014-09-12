require_relative 'builder'
require_relative '../utilities'
require_relative '../schema'
require_relative '../queriers/parameters_querier'

class ParametersBuilder < Builder

  extend Initializer
  initialize_with ({
    querier: ParametersQuerier.new
  })

  def build ast
    @ast = ast
    parameters
  end

  def parameters
    functions_parameters << klasses_methods_parameters
  end

  def functions_parameters
    querier.functions_parameters(ast).map_unique do |function_parameter_ast|
      parameter = Parameter.find_or_create_by(
        unique_name: querier.function_parameter_unique_name(function_parameter_ast),
        name: querier.function_parameter_name(function_parameter_ast),
        procedure: parent_function(function_parameter_ast)
      )
    end
  end

  def klasses_methods_parameters
    querier.klasses_methods_parameters(ast).map_unique do |klass_method_parameter_ast|
      parameter = Parameter.find_or_create_by(
        unique_name: querier.klass_method_parameter_unique_name(klass_method_parameter_ast),
        name: querier.klass_method_parameter_name(klass_method_parameter_ast),
        procedure: parent_klass_method(klass_method_parameter_ast)
      )
    end
  end

  def parent_function ast
    Function.find_or_create_by(
      unique_name: querier.parent_function_unique_name(ast),
      name: querier.parent_function_name(ast)
    )
  end

  def parent_klass_method ast
    KlassMethod.find_or_create_by(
      unique_name: querier.parent_klass_method_unique_name(ast),
      name: querier.parent_klass_method_name(ast)
    )
  end

end
