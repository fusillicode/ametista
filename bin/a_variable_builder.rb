require_relative 'utilities'
require_relative 'model'
require_relative 'a_variable_ast_querier'

class AVariableBuilder

  extend Initializer
  initialize_with ({
    querier: AVariableAstQuerier.new,
  })

  def build brick
    @querier.brick = brick
    variable
  end

  # has_many :assignements, class_name: 'AnAssignement', inverse_of: :variable
  # has_and_belongs_to_many :types, class_name: 'AType', inverse_of: :variables
  # field :name, type: String
  # field :unique_name, type: String
  # index({ unique_name: 1 }, { unique: true })

  def variable
    variable = AVariable.create(

    )
  end

end

