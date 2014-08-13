require_relative 'initializer'
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
    querier: ANamespaceAstQuerier.new,
    an_assignement_builder: AnAssignementBuilder.new,
    a_branch_builder: ABranchBuilder.new,
    a_function_builder: AFunctionBuilder.new,
    a_class_builder: AClassBuilder.new
  })

  def build ast = nil
    @ast ||= ast
    global_namespace
  end

  def global_namespace
    global_namespace = ANamespace.find_or_create_by(
      unique_name: '\\',
      name: '\\'
    )
    # global_namespace.assignements.concat(assignements)
    # global_namespace.branches.concat(branches)
    # global_namespace.functions.concat(functions)
    # global_namespace.classes.concat(classes)
    global_namespace.subnamespaces.concat(namespaces)
  end

  def namespaces
    querier.namespaces(ast).map do |namespace_ast|
      @ast = namespace_ast
      namespace
    end
  end

  def namespace
    first_namespace, last_namespace = inline_namespaces.first_and_last
    # last_namespace.assignements.concat(assignements)
    # last_namespace.branches.concat(branches)
    # last_namespace.functions = functions
    # last_namespace.classes = classes
    first_namespace
  end

  def inline_namespaces
    inline_namespaces_ast = querier.inline_namespaces(ast)
    return one_inline_namespace(inline_namespaces_ast) ||
           multiple_inline_namespaces(inline_namespaces_ast)
  end

  def one_inline_namespace(inline_namespaces_ast)
    return nil if inline_namespaces_ast.count != 1
    name = inline_namespaces_ast.first.text
    unique_name = "#{unique_name}\\#{name}"
    return [ ANamespace.find_or_create_by(
              unique_name: unique_name,
              name: name
            ) ]
  end

  def multiple_inline_namespaces(inline_namespaces_ast)
    parent_unique_name = ''
    inline_namespaces = []
    inline_namespaces_ast.each_with_index do |parent, i|
      parent_name = parent.text
      parent_unique_name = "#{parent_unique_name}\\#{parent_name}"
      child_name = inline_namespaces_ast[i + 1].text
      parent = ANamespace.find_or_create_by(
        unique_name: parent_unique_name,
        name: parent_name
      )
      child = parent.subnamespaces.find_or_create_by(
        unique_name: "#{parent_unique_name}\\#{child_name}",
        name: child_name
      )
      inline_namespaces << parent
      if i == inline_namespaces_ast.size - 2
        inline_namespaces << child
        break
      end
    end
    inline_namespaces
  end

  def assignements
    querier.assignements(ast).map do |assignement_ast|
      querier.variable_name(assignement_ast)
      # an_assignement_builder.build(assignement_ast)
      # AnAssignement.find_or_create_by(
      #   unique_name: '\\',
      #   name: '\\'
      # )
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

