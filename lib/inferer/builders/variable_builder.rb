require_relative '../utilities'
require_relative '../schema'
require_relative '../queriers/variable_ast_querier'

class VariableBuilder

  extend Initializer
  initialize_with ({
    querier: VariableAstQuerier.new,
  })

  def build ast
    @querier.ast = ast
    variable
  end

  # has_many :assignements, class_name: 'AnAssignement', inverse_of: :variable
  # has_and_belongs_to_many :types, class_name: 'AType', inverse_of: :variables
  # field :name, type: String
  # field :unique_name, type: String
  # index({ unique_name: 1 }, { unique: true })

  def variable
    p querier.variable_unique_name
    # variable = AVariable.create(
    #   name: querier.variable_name,
    #   unique_name: querier.variable_unique_name
    # )
  end

end

