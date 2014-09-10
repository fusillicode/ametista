require_relative '../utilities'
require_relative '../schema'
require_relative '../queriers/assignements_querier'

# require_relative 'variables_builder'
# require_relative 'namespaces_builder'
# require_relative 'functions_builder'
# require_relative 'klasses_builder'
# require_relative 'klasses_method_builder'
# require_relative 'branches_builder'

# class AssignementBuilder

#   extend Initializer
#   initialize_with ({
#     querier: AssignementAstQuerier.new,
#     variable_builder: VariableBuilder.new
#   })

#   def build ast
#     @querier.ast = ast
#     assignements
#   end

#   def assignements
#     querier.assignements.each do |assignement_ast|
#       p scope(assignement_ast)
#       # AnAssignement.create(
#       #   variable: variable(assignement_ast),
#       #   rhs: querier.rhs(assignement_ast),
#       #   scope: scope(assignement_ast)
#       # )
#     end
#   end

#   def scope ast
#     scope = querier.scope(ast)
#     p Namespace.new
#     p Method.new
#     exit
#     scope.type.find_or_create_by(
#       unique_name: scope.unique_name,
#       name: scope.name
#     )
#   end

#   def variable ast
#     Variable.find_or_create_by(
#       unique_name: 'ciccia',
#       name: 'cic'
#     )
#     # a_variable_builder.build()
#   end

# end

