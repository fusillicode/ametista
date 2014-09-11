require_relative 'builder'
require_relative '../utilities'
require_relative '../schema'
require_relative '../queriers/local_variables_querier'

class LocalVariablesBuilder < Builder

  extend Initializer
  initialize_with ({
    querier: LocalVariablesAstQuerier.new,
    ast: nil
  })

  def build ast
    @ast = ast
    local_variables
  end

  def local_variables
    p querier.local_variables(ast).count
    querier.local_variables(ast).map_unique do |local_variable_ast|
      LocalVariable.find_or_create_by(
        # unique_name: querier.local_variable_unique_name(local_variable_ast),
        # name: querier.local_variable_name(local_variable_ast)
        unique_name: 'asd',
        name: 'asd'
      )
    end
  end

end
