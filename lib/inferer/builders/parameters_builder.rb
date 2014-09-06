require_relative 'builder'
require_relative '../utilities'
require_relative '../schema'
require_relative '../queriers/parameters_ast_querier'

class ParametersBuilder < Builder

  extend Initializer
  initialize_with ({
    querier: ParametersAstQuerier.new,
    ast: nil
  })

  def build ast
    @ast = ast
    parameters
  end

  def parameters
    querier.parameters(ast).map_unique do |parameter_ast|
      parameter = Parameter.find_or_create_by(
        unique_name: querier.unique_name(parameter_ast),
        name: querier.name(parameter_ast),
        procedure: parent(parameter_ast)
      )
      add_type(parameter, parameter_ast)
    end
  end

  def parent ast
    querier.parent_type(ast).find_or_create_by(
      unique_name: querier.parent_unique_name(ast),
      name: querier.parent_name(ast)
    )
  end

  def add_type parameter, ast
    return parameter unless type = querier.type(ast)
    type.find_or_create_by(
      unique_name: querier.type_unique_name(ast),
      name: querier.type_name(ast),
    ).variables << parameter
    parameter
  end

end
