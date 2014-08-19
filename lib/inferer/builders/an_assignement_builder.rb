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
    scope_builder:
    {
      namespace_builder: ANamespaceBuilder.new,
      function_builder: AFunctionBuilder.new,
      class_builder: AClassBuilder.new,
      method_builder: AMethodBuilder.new,
      branch_builder: ABranchBuilder.new
    }
  })

  def build ast
    @querier.ast = ast
    assignements
  end

  def assignements
    querier.assignements.each do |assignement_ast|
      AnAssignement.create(
        variable: variable(assignement_ast),
        rhs: querier.rhs(assignement_ast)
        scope: scope(assignement_ast)
      )
    end
  end

  def scope ast
    scope_builder[querier.scope_type(ast)].find_or_create_by(
      unique_name: querier.scope_unique_name(ast),
      name: querier.scope_name(ast)
    )
  end

  def variable ast
    a_variable_builder.build()
  end

end

