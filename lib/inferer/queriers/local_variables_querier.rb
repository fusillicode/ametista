require_relative 'querier'

class LocalVariablesAstQuerier < Querier

  def local_variables ast
    functions_local_variables(ast) # << klass_methods_local_variables(ast)
  end

  def functions_local_variables ast
    ast.xpath(".//node:Expr_Assign/descendant::node:Expr_Variable[subNode:name/scalar:string[#{not_superglobals})]]")
  end

  def not_superglobals
    "not(#{superglobals})"
  end

  def superglobals
    language.superglobals.map{ |superglobal| "text() = '#{superglobal}'" }.join(" or ")
  end

  # def klass_methods_local_variables ast
  #   ast.xpath(".//node:Expr_Assign/ancestor::node:Stmt_ClassMethod[1] and descendant::node:Expr_ArrayDimFetch[last()][subNode:var/node:Expr_Variable[subNode:name/scalar:string[#{superglobals_list('and')}]]]")
  # end

  def unique_name ast

  end

  def name ast

  end

end
