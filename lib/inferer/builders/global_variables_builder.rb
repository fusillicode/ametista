require_relative '../utilities'
require_relative '../schema'
require_relative '../queriers/global_variables_ast_querier'

class GlobalVariablesBuilder

  extend Initializer
  initialize_with ({
    querier: GlobalVariablesAstQuerier.new,
  })

  def build ast
    @querier.ast = ast
    global_variables
  end

  def global_variables
    ciccio = querier.global_variables.map do |global_variable_ast|
      global_variable_ast
      # GlobalVariable.find_or_create_by(
      #   unique_name: querier.unique_name(global_variable_ast),
      #   name: querier.name(global_variable_ast)
      # )
    end
    p ciccio.count
    exit
  end

  # has_many :assignements, class_name: 'AnAssignement', inverse_of: :variable
  # has_and_belongs_to_many :types, class_name: 'AType', inverse_of: :variables
  # field :name, type: String
  # field :unique_name, type: String
  # index({ unique_name: 1 }, { unique: true })

end
