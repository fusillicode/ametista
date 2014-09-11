require_relative 'querier'

class LocalVariablesAstQuerier < Querier

  def local_variables ast
    functions_local_variables(ast) # << klass_methods_local_variables(ast)
  end

  def functions_local_variables ast
    ast.xpath(".//node:Expr_Assign/descendant::node:Expr_Variable[subNode:name/scalar:string[not(#{superglobals_list('or')})]]")
  end

  def superglobals_list compare_operator = '=', join_operator = 'and'
    language.superglobals.map{ |superglobal| "text() #{compare_operator} '#{superglobal}'" }.join(" #{join_operator} ")
  end

  # def klass_methods_local_variables ast
  #   ast.xpath(".//node:Expr_Assign/ancestor::node:Stmt_ClassMethod[1] and descendant::node:Expr_ArrayDimFetch[last()][subNode:var/node:Expr_Variable[subNode:name/scalar:string[#{superglobals_list('and')}]]]")
  # end

  def unique_name ast

  end

  def name ast

  end

end
