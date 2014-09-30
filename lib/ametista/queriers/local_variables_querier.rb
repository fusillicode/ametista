require_relative 'querier'

class LocalVariablesQuerier < Querier

  def functions_local_variables ast_root
    ast_root.xpath(".//node:Expr_Assign/descendant::node:Expr_Variable[ancestor::node:Stmt_Function[1] and subNode:name/scalar:string[#{a_local_variable}]]")
  end

  def klass_methods_local_variables ast_root
    ast_root.xpath(".//node:Expr_Assign/descendant::node:Expr_Variable[ancestor::node:Stmt_ClassMethod[1] and subNode:name/scalar:string[#{a_local_variable}]]")
  end

  def function_local_variable_name ast
    ast.xpath('./subNode:name/scalar:string').text
  end

  def function_local_variable_unique_name ast
    "#{function_unique_name(ast)}#{namespace_separator}#{function_local_variable_name(ast)}"
  end

  def function_unique_name ast
    "#{namespace_unique_name(ast)}#{namespace_separator}#{function_name(ast)}"
  end

  def namespace_unique_name ast
    "#{global_namespace_unique_name}#{namespace_separator}#{ast.xpath('./ancestor::node:Stmt_Namespace[1]/subNode:name/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('\\')}"
    exit
  end

  def function_name ast
    ast.xpath("./ancestor::node:Stmt_Function/subNode:name/scalar:string").text
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
    "#{global_namespace_unique_name}#{namespace_separator}#{ast.xpath('./ancestor::node:Stmt_Class[1]/subNode:namespacedName/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('\\')}"
  end

  def klass_method_name ast
    ast.xpath("./ancestor::node:Stmt_ClassMethod/subNode:name/scalar:string").text
  end

end
