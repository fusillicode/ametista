require_relative 'assignement_querier'

class LocalVariablesQuerier < AssignementQuerier

  def namespaces_local_variables ast_root
    ast_root.xpath(".//node:Stmt_Namespace/subNode:stmts/scalar:array/node:Expr_Assign/descendant::node:Expr_Variable[subNode:name/scalar:string[#{a_local_variable}]]")
  end

  def functions_variables ast_root
    ast_root.xpath(".//node:Expr_Assign/descendant::node:Expr_Variable[ancestor::node:Stmt_Function[1] and subNode:name/scalar:string[#{a_local_variable}]]")
  end

  def functions_local_variables ast_root
    functions_variables(ast_root).map { |function_variable_ast|
      next if is_global_defined_variable?(
        function_local_variable_name(function_variable_ast),
        function_variable_ast
      )
      function_variable_ast
    }.compact()
  end

  def is_global_defined_variable? variable_name, variable_ast
    return variable_name if previous_global_variables_definitions_names(variable_ast).include? variable_name
  end

  def klasses_methods_local_variables ast_root
    ast_root.xpath(".//node:Expr_Assign/descendant::node:Expr_Variable[ancestor::node:Stmt_ClassMethod[1] and subNode:name/scalar:string[#{a_local_variable}]]")
  end

  def previous_global_variables_definitions_names ast
    ast.xpath("./ancestor::node:Expr_Assign[1]/preceding-sibling::node:Stmt_Global/subNode:vars/scalar:array/node:Expr_Variable/subNode:name/scalar:string").map { |global_variable| global_variable.text }
  end

  def function_local_variable_name ast
    ast.xpath('./subNode:name/scalar:string').text
  end

  def klass_method_local_variable_name ast
    ast.xpath('./subNode:name/scalar:string').text
  end

  def function_local_variable_unique_name ast
    "#{function_unique_name(ast)}#{namespace_separator}#{function_local_variable_name(ast)}"
  end

  def function_unique_name ast
    "#{namespace_unique_name(ast)}#{namespace_separator}#{function_name(ast)}"
  end

  def namespace_unique_name ast
    namespace_name_parts = namespace_name_parts(ast)
    namespace_name_parts.empty? ?
      global_namespace_unique_name :
      "#{global_namespace_unique_name}#{namespace_separator}#{namespace_name_parts(ast)}"
  end

  def namespace_name ast
    namespace_name = ast.xpath('./ancestor::node:Stmt_Namespace[1]/subNode:name/node:Name/subNode:parts/scalar:array/scalar:string[last()]').text
    namespace_name.empty? ?
      global_namespace_name :
      namespace_name
  end

  def namespace_name_parts ast
    ast.xpath('./ancestor::node:Stmt_Namespace[1]/subNode:name/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join(namespace_separator)
  end

  def function_name ast
    ast.xpath("./ancestor::node:Stmt_Function[1]/subNode:name/scalar:string").text
  end

  def namespace_local_variable_name ast
    ast.xpath('./subNode:name/scalar:string').text
  end

  def namespace_local_variable_unique_name ast
    "#{namespace_unique_name(ast)}#{namespace_separator}#{namespace_local_variable_name(ast)}"
  end

  def klass_method_local_variable_name ast
    ast.xpath('./subNode:name/scalar:string').text
  end

  def klass_method_local_variable_unique_name ast
    "#{klass_method_unique_name(ast)}#{namespace_separator}#{klass_method_local_variable_name(ast)}"
  end

  def klass_method_unique_name ast
    "#{klass_unique_name(ast)}#{namespace_separator}#{klass_method_name(ast)}"
  end

  def klass_unique_name ast
    "#{global_namespace_unique_name}#{namespace_separator}#{klass_namespaced_name(ast)}"
  end

  def klass_namespaced_name ast
    ast.xpath('./ancestor::node:Stmt_Class[1]/subNode:namespacedName/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join(namespace_separator)
  end

  def klass_method_name ast
    ast.xpath("./ancestor::node:Stmt_ClassMethod[1]/subNode:name/scalar:string").text
  end

end
