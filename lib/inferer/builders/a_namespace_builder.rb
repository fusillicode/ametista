require_relative '../utilities'
require_relative '../schema'
require_relative '../queriers/a_namespace_ast_querier'
require_relative 'a_branch_builder'
require_relative 'an_assignement_builder'
require_relative 'a_function_builder'
require_relative 'a_class_builder'

class ANamespaceBuilder

  extend Initializer
  initialize_with ({
    querier: ANamespaceAstQuerier.new,
    an_assignement_builder: AnAssignementBuilder.new,
    a_branch_builder: ABranchBuilder.new,
    a_function_builder: AFunctionBuilder.new,
    a_class_builder: AClassBuilder.new
  })

  def build ast
    @querier.ast_decorator.decore(ast)
    global_namespace
    namespaces
  end

  def global_namespace
    global_namespace = ANamespace.find_or_create_by(
      unique_name: querier.global_namespace_unique_name,
      name: querier.global_namespace_name
    )
    # global_namespace.assignements.concat(assignements)
    # global_namespace.branches.concat(branches)
    # global_namespace.functions.concat(functions)
    # global_namespace.classes.concat(classes)
    # global_namespace
  end

  def namespaces
    querier.namespaces.map do |namespace_ast|
      @querier.ast = namespace_ast
      namespace
    end
  end

  def namespace
    namespace = ANamespace.find_or_create_by(
      unique_name: querier.namespace_unique_name,
      name: querier.namespace_name
    )
    namespace.assignements.concat(assignements)
    # namespace.branches.concat(branches)
    # namespace.functions.concat(functions)
    # namespace.classes.concat(classes)
    # namespace
  end

  def assignements()
    querier.assignements.map do |assignement_ast|
      an_assignement_builder.build(assignement_ast)
    end
  end

  def branches
    querier.branches.map do |branch_ast|
      a_branch_builder.build(branch_ast)
    end
  end

  def functions
    querier.functions.map do |function_ast|
      a_function_builder.build(function_ast)
    end
  end

  def classes
    querier.classes.map do |class_ast|
      a_class_builder.build(class_ast)
    end
  end

end

