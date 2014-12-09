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

  def function ast
    ast.xpath("./ancestor::node:Stmt_Function[1]")
  end

  def klass_method ast
    ast.xpath("./ancestor::node:Stmt_ClassMethod[1]")
  end

end
