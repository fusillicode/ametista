require_relative '../utilities'
require_relative '../schema'
require_relative '../queriers/an_assignement_ast_querier'
require_relative 'a_variable_builder'

class AnAssignementBuilder

  extend Initializer
  initialize_with ({
    querier: AnAssignementAstQuerier.new,
    a_variable_builder: AVariableBuilder.new
  })

  def build ast
    @querier.ast = ast
    assignement
  end

  def assignement
    assignement = AnAssignement.create(
      variable: variable,
      rhs: querier.rhs
    )
  end

  def variable
    a_variable_builder.build(querier.variable)
  end

end

