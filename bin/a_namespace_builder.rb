require_relative 'initializer'
require_relative 'a_namespace_ast_querier'
require_relative 'model'

class ANamespaceBuilder

  extend Initializer
  initialize_with ({
    ast: nil,
    querier: ANamespaceAstQuerier.new
  })

  def build ast = nil
    @ast ||= ast
    build_global_namespace
  end

  def build_global_namespace
    global_namespace = ANamespace.find_or_create_by(
      unique_name: '\\',
      name: '\\'
    )
    global_namespace.assignements.concat(build_assignements)
    # global_namespace.branches.concat(build_branches)
    # global_namespace.functions.concat(build_functions)
    # global_namespace.classes.concat(build_classes)
    global_namespace.subnamespaces.concat(build_namespaces)
  end

  def build_assignements
    querier.assignements(ast).map do |assignement_ast|
      AnAssignement.find_or_create_by(
        unique_name: '\\',
        name: '\\'
      )
    end
  end

  def build_brances

  end

  def build_functions
    querier.functions(ast).map do |function_ast|
      AFunctionBuilder.build(function_ast)
    end
  end

  def build_classes
    querier.classes(ast).map do |class_ast|
      AClassBuilder.build(class_ast)
    end
  end

  def build_namespaces
    querier.namespaces(ast).map do |namespace_ast|
      @ast = namespace_ast
      build_namespace
    end
  end

  def build_namespace
    inline_namespaces = build_inline_namespaces
    # inline_namespaces.last.functions = build_functions
    # inline_namespaces.last.classes = build_classes
    inline_namespaces.first
  end

  def build_inline_namespaces
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
    inline_namespaces = inline_namespaces_ast.each_cons(2).map do |namespaces|
      parent_name = namespaces.first.text
      parent_unique_name = "#{parent_unique_name}\\#{parent_name}"
      child_name = namespaces.second.text
      parent = ANamespace.find_or_create_by(
        unique_name: parent_unique_name,
        name: parent_name
      )
      child = parent.subnamespaces.find_or_create_by(
        unique_name: "#{parent_unique_name}\\#{child_name}",
        name: child_name
      )
      parent
    end
  end

  def build_global_variables
      querier.assignements.each do |global_variable|
        p querier.variable_name(global_variable)
      end
      # global_variables.each do |global_variable|
      # global_variable_name = variable_name(global_variable_value)
      # AVariable.create(:unique_name => global_variable_name,
      #                  :name => global_variable_name,
      #                  :type => 'global',
      #                  :value => global_variable_value(global_variable_value),
      #                  :i_procedure => model.send("current_#{procedure_type}"))
      # end
  end

  def subnamespace_unique_name(subnamespace)
    "#{builded_entity[:model].unique_name}\\#{subnamespace.text}"
  end

end

