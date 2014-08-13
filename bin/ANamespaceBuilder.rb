class ANamespaceAstQuerier

  def namespaces(ast)
    ast.xpath('.//node:Stmt_Namespace')
  end

  def inline_namespaces(ast)
    ast.xpath('./subNode:name/node:Name/subNode:parts/scalar:array/scalar:string')
  end

  def namespace_name(ast)
    ast.xpath('./subNode:name/node:Name/subNode:parts/scalar:array/scalar:string[last()]').text
  end

  def namespace_unique_name(ast)
    subnamespaces = ast.xpath('./subNode:name/node:Name/subNode:parts/scalar:array/scalar:string')
    subnamespaces.map{ |subnamespace| "\\#{subnamespace.text}" }.join
  end

  def statements(ast)
    ast.xpath('./subNode:stmts/scalar:array/*[name() != "node:Stmt_Function" and name() != "node:Stmt_Class"]')
  end

  # le variabili assegnate
  def assignements(ast)
    ast.xpath('./subNode:stmts/scalar:array/node:Expr_Assign/subNode:var')
  end

  def global_variable_value(global_variable)
    global_variable.xpath('./subNode:expr')
  end

  def variable_name(node)

    node = node.xpath('./*[1]')[0]

    case node.name
    when 'Expr_Variable'
      name = node.xpath('./subNode:name/scalar:string').text
      # non tratto le variabili di variabli (e.g. $$v)
      return false if name.nil? or name.empty?
      # le variabili plain assegnate sono comunque in GLOBALS
      return "GLOBALS[#{name}]" if name != 'GLOBALS'
      name
    when 'Expr_PropertyFetch'
      # non tratto proprietà con nomi dinamici
      return false if !var = variable_name(node.xpath('./subNode:var'))
      return false if !name = variable_name(node.xpath('./subNode:name'))
      var << '->' << name
    when 'Expr_ArrayDimFetch'
      # non tratto indici di array dinamici
      return var if !var = variable_name(node.xpath('./subNode:var'))
      dim = node.xpath('./subNode:dim/*[name() = "node:Scalar_String" or name() = "node:Scalar_LNumber"]/subNode:value/*').text
      return false if dim.nil? or dim.empty?
      var << '[' << dim << ']'
    when 'string'
      node.text
    else
      false
    end

  end

  def functions(ast)
    ast.xpath('./subNode:stmts/scalar:array/node:Stmt_Function')
  end

  def classes(ast)
    ast.xpath('./subNode:stmts/scalar:array/node:Stmt_Class')
  end

end

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
      name:        '\\'
    )
    # global_namespace.functions = build_functions
    # global_namespace.classes = build_classes
    global_namespace.subnamespaces.concat(build_namespaces)
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

  def subnamespace_unique_name(subnamespace)
    "#{builded_entity[:model].unique_name}\\#{subnamespace.text}"
  end

end

