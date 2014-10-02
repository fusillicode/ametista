require_relative 'builder'
require_relative '../utilities'
require_relative '../schema'
require_relative '../queriers/local_variables_querier'

class LocalVariablesBuilder < Builder

  extend Initializer
  initialize_with ({
    querier: LocalVariablesQuerier.new
  })

  def build ast
    @ast = ast
    local_variables
  end

  def local_variables
    functions_local_variables # << klasses_methods_local_variables
  end

  def functions_local_variables
    querier.functions_local_variables(ast).map_unique do |function_local_variable_ast|
      LocalVariable.find_or_create_by(
        name: querier.function_local_variable_name(function_local_variable_ast),
        local_scope: function(function_local_variable_ast)
      )
    end
  end

  def klasses_methods_local_variables
    querier.klasses_methods_local_variables(ast).map_unique do |klass_method_local_variable_ast|
      LocalVariable.find_or_create_by(
        name: querier.klass_method_local_variable_name(local_variable_ast),
        local_scope: klass_method(klass_method_local_variable_ast)
      )
    end
  end

  def function function_local_variable_ast
    Function.find_or_create_by(
      unique_name: querier.function_unique_name(function_local_variable_ast),
      name: querier.function_name(function_local_variable_ast)
    )
  end

  def klass_method klass_method_local_variable_ast
    KlassMethod.find_or_create_by(
      unique_name: querier.klass_method_unique_name(klass_method_local_variable_ast),
      name: querier.klass_method_name(klass_method_local_variable_ast)
    )
  end

end
