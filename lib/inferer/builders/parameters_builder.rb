require_relative '../utilities'
require_relative '../schema'
require_relative '../queriers/parameters_ast_querier'


class ParametersBuilder

  extend Initializer
  initialize_with ({
    querier: ParametersAstQuerier.new
  })

  def build ast
    @querier.ast = ast
    parameters
  end

  def parameters
    querier.parameters.map_unique do |parameter_ast|
      parameter = Parameter.find_or_create_by(
        unique_name: querier.unique_name(parameter_ast),
        name: querier.name(parameter_ast),
        procedure: parent(parameter_ast)
      )
      parameter.types << type(parameter_ast)
      parameter
    end
  end

  def parent ast
    querier.parent_type(ast).find_or_create_by(
      unique_name: querier.parent_unique_name(ast),
      name: querier.parent_name(ast)
    )
  end

  def type ast
    querier.type(ast).find_or_create_by(
      unique_name: querier.type_unique_name(ast),
      name: querier.type_name(ast)
    )
  end

end
