require_relative 'querier'
# has_one :variable, class_name: 'AVariable', inverse_of: :assignements
# belongs_to :scope, class_name: 'AScope', inverse_of: :assignements
# field :RHS, type: String

class AnAssignementAstQuerier < Querier

  def get_variable(ast)

  end

  def get_rhs(ast)

  end

end
