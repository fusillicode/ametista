require_relative 'querier'

class LocalVariablesQuerier < Querier

  def namespaces_local_variables ast_root
    ast_root.xpath(".//Stmt_Namespace/stmts/array/Expr_Assign/descendant::Expr_Variable[name/string[#{a_local_variable}]]")
  end

  def functions_variables ast_root
    ast_root.xpath(".//Expr_Assign/descendant::Expr_Variable[ancestor::Stmt_Function[1] and name/string[#{a_local_variable}]]")
  end

  def functions_local_variables ast_root
    functions_variables(ast_root).map { |function_variable_ast|
      next if is_global_defined_variable?(
        name(function_variable_ast),
        function_variable_ast
      )
      function_variable_ast
    }.compact()
  end

  def is_global_defined_variable? variable_name, variable_ast
    return variable_name if previous_global_variables_definitions_names(variable_ast).include? variable_name
  end

  def klasses_methods_local_variables ast_root
    ast_root.xpath(".//Expr_Assign/descendant::Expr_Variable[ancestor::Stmt_ClassMethod[1] and name/string[#{a_local_variable}]]")
  end

  def previous_global_variables_definitions_names ast
    ast.xpath('./ancestor::Expr_Assign[1]/preceding-sibling::Stmt_Global/vars/array/Expr_Variable/name/string').map { |global_variable| global_variable.text }
  end

end
