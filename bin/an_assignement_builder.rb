require_relative 'utilities'
require_relative 'model'
require_relative 'an_assignement_ast_querier'

class AnAssignementBuilder

  extend Initializer
  initialize_with ({
    querier: AnAssignementAstQuerier.new,
    a_variable_builder: AnAssignementBuilder.new
  })

  def build brick
    querier.brick = brick
    assignement
  end

  def assignement
    AnAssignement.find_or_create_by(
      unique_name: '\\',
      name: '\\'
    )
  end

end

