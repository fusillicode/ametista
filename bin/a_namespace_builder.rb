require_relative 'utilities'
require_relative 'model'
require_relative 'a_namespace_ast_querier'
require_relative 'a_branch_builder'
require_relative 'an_assignement_builder'
require_relative 'a_function_builder'
require_relative 'a_class_builder'

class ANamespaceBuilder

  extend Initializer
  initialize_with ({
    ast: nil,
    root_unique_name: '\\',
    parent_unique_name: '\\',
    querier: ANamespaceAstQuerier.new,
    an_assignement_builder: AnAssignementBuilder.new,
    a_branch_builder: ABranchBuilder.new,
    a_function_builder: AFunctionBuilder.new,
    a_class_builder: AClassBuilder.new
  })

  def build args
    set_instance_variables(args)
    global_namespace
    namespaces
  end

  def global_namespace
    reset_parent_unique_name
    global_namespace = ANamespace.find_or_create_by(
      unique_name: root_unique_name,
      name: root_unique_name
    )
    # global_namespace.assignements.concat(assignements)
    # global_namespace.branches.concat(branches)
    # global_namespace.functions.concat(functions)
    # global_namespace.classes.concat(classes)
  end

  def namespaces
    querier.namespaces(ast).map do |namespace_ast|
      set_instance_variables({
        ast: namespace_ast,
        parent_unique_name: querier.namespace_unique_name(namespace_ast, root_unique_name)
      })
      namespace
      reset_parent_unique_name
    end
  end

  def namespace
    namespace = ANamespace.find_or_create_by(
      unique_name: parent_unique_name,
      name: parent_unique_name.name_from_unique_name
    )
    # namespace.assignements.concat(assignements)
    # namespace.branches.concat(branches)
    # namespace.functions.concat(functions)
    # namespace.classes.concat(classes)
    # namespace
  end

  def assignements()
    querier.assignements(ast).map do |assignement_ast|
      # querier.variable_name(assignement_ast)
      an_assignement_builder.build(assignement_ast)
    end
  end

  def branches

  end

  def functions
    querier.functions(ast).map do |function_ast|
      a_function_builder.build(function_ast)
    end
  end

  def classes
    querier.classes(ast).map do |class_ast|
      a_class_builder.build(class_ast)
    end
  end

  def reset_parent_unique_name
    @parent_unique_name = root_unique_name
  end

  # def global_variables
  #     querier.assignements.each do |global_variable|
  #       p querier.variable_name(global_variable)
  #     end
  #     # global_variables.each do |global_variable|
  #     # global_variable_name = variable_name(global_variable_value)
  #     # AVariable.create(:unique_name => global_variable_name,
  #     #                  :name => global_variable_name,
  #     #                  :type => 'global',
  #     #                  :value => global_variable_value(global_variable_value),
  #     #                  :i_procedure => model.send("current_#{procedure_type}"))
  #     # end
  # end

end

