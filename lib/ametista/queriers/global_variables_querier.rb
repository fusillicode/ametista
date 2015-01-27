require_relative 'querier'

class GlobalVariablesQuerier < Querier

  def global_namespace_variables ast_root
    ast_root.xpath("/AST/array/Expr_Assign/descendant::Expr_Variable[name/string[#{not_a_superglobal}]]")
  end

  def global_definitions ast_root
    ast_root.xpath(".//Stmt_Global/vars/array/descendant::Expr_Variable[name/string[#{not_a_superglobal}]]")
  end

  def superglobals ast_root
    ast_root.xpath(".//Expr_Assign/descendant::Expr_ArrayDimFetch[last()][var/Expr_Variable[name/string[#{a_superglobal}]]]")
  end

  def defined_constants ast_root
    ast_root.xpath(".//Expr_FuncCall[name/Name/parts/array/string[text() = 'define']]")
  end

  def klass_constants ast_root
    ast_root.xpath(".//Expr_FuncCall/name/Name/parts/array/string/define")
  end

  def superglobal_type ast
    ast.xpath('./var/Expr_Variable/name/string').text
  end

  def superglobal_name ast
    ast.xpath('./dim/Scalar_String/value/string').text
  end

  def defined_constant_name ast
    ast.xpath('./args/array/*[1]/value/Expr_ConstFetch/name/Name/parts/array/string').text
  end

end
