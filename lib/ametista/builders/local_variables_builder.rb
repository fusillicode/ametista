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
    functions_local_variables
  end

  def functions_local_variables
    querier.functions_local_variables(ast).map_unique do |function_local_variable_ast|
      p querier.function_local_variable_unique_name(function_local_variable_ast)
      # LocalVariable.find_or_create_by(
      #   # unique_name: querier.local_variable_unique_name(local_variable_ast),
      #   # name: querier.local_variable_name(local_variable_ast)
      #   unique_name: 'asd',
      #   name: 'asd'
      # )
    end
  end

end
