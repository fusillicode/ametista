require_relative '../utilities'
require_relative '../schema'
require_relative '../queriers/an_assignement_ast_querier'
require_relative 'a_variable_builder'
require_relative 'a_namespace_builder'
require_relative 'a_function_builder'
require_relative 'a_class_builder'
require_relative 'a_method_builder'
require_relative 'a_branch_builder'

class AnAssignementBuilder

  extend Initializer
  initialize_with ({
    querier: AnAssignementAstQuerier.new,
    variable_builder: AVariableBuilder.new
  })

  def build ast
    @querier.ast = ast
    assignements
  end

  def assignements
    querier.assignements.each do |assignement_ast|
      p scope(assignement_ast)
      # AnAssignement.create(
      #   variable: variable(assignement_ast),
      #   rhs: querier.rhs(assignement_ast),
      #   scope: scope(assignement_ast)
      # )
    end
  end

  def scope ast
    scope = querier.scope(ast)
    p ANamespace.new
    p AMethod.new
    exit
    scope.type.find_or_create_by(
      unique_name: scope.unique_name,
      name: scope.name
    )
  end

  def variable ast
    AVariable.find_or_create_by(
      unique_name: 'ciccia',
      name: 'cic'
    )
    # a_variable_builder.build()
  end

end

