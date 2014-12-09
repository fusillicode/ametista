require_relative 'builder'
require_relative '../utilities'
require_relative '../schema'
require_relative '../queriers/assignement_querier.rb'

class AssignementBuilder < Builder

  extend Initializer
  initialize_with ({
    querier: AssignementQuerier.new
  })

  def assignement ast
    Assignement.create(
      variable: variable,
      position: querier.position(ast),
      rhs: querier.rhs(ast)
    )
  end

end
