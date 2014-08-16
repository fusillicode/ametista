require_relative '../utilities'
require_relative '../model'
require_relative '../brick'
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

  def build brick
    @querier.brick = brick
    global_namespace
    namespaces
  end

  def global_namespace
    querier.parent_as_root
    global_namespace = ANamespace.find_or_create_by(
      unique_name: querier.root_unique_name,
      name: querier.root_unique_name
    )
    # global_namespace.assignements.concat(assignements)
    # global_namespace.branches.concat(branches)
    # global_namespace.functions.concat(functions)
    # global_namespace.classes.concat(classes)
    # global_namespace
  end

  def namespaces
    querier.parent_as_root
    querier.namespaces.map do |namespace_ast|
      @querier.brick.ast = namespace_ast
      @querier.parent_unique_name = querier.namespace_unique_name
      namespace
    end
  end

  def namespace
    namespace = ANamespace.find_or_create_by(
      unique_name: querier.parent_unique_name,
      name: querier.parent_name
    )
    namespace.assignements.concat(assignements)
    # namespace.branches.concat(branches)
    # namespace.functions.concat(functions)
    # namespace.classes.concat(classes)
    # namespace
  end

  def assignements()
    querier.assignements.map do |assignement_ast|
      @querier.brick.ast = assignement_ast
      an_assignement_builder.build(querier.brick)
    end
  end

  def branches
    querier.branches.map do |branch_ast|
      @querier.brick.ast = branch_ast
      a_branch_builder.build(querier.brick)
    end
  end

  def functions
    querier.functions.map do |function_ast|
      @querier.brick.ast = function_ast
      a_function_builder.build(querier.brick)
    end
  end

  def classes
    querier.classes.map do |class_ast|
      @querier.brick.ast = class_ast
      a_class_builder.build(querier.brick)
    end
  end

end
