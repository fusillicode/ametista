require_relative '../utilities'
require_relative '../schema'
require_relative '../queriers/function_ast_querier'

class FunctionBuilder

  extend Initializer
  initialize_with ({
    querier: FunctionAstQuerier.new
  })

  def build ast
    @querier.ast = ast
    functions
  end

  def functions
    querier.functions.map_unique do |function_ast|
      Function.find_or_create_by(
        unique_name: querier.unique_name(function_ast),
        name: querier.name(function_ast),
        namespace: parent(function_ast),
        return_values: return_values(function_ast)
      )
    end
  end

  def parent ast
    Namespace.find_or_create_by(
      unique_name: querier.parent_unique_name(ast),
      name: querier.parent_name(ast)
    )
  end

  # TODO formalizzare la persistenza dei return_values
  def return_values ast
    querier.return_values(ast).map do |return_value|
      return_value.to_s
    end
  end

end
