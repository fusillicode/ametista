require_relative 'querier'

class LocalVariablesAstQuerier < Querier

  def local_variables ast
    functions_local_variables(ast) # << klass_methods_local_variables(ast)
  end

  def functions_local_variables ast
    ast.xpath(".//node:Expr_Assign/descendant::node:Expr_Variable[ancestor::node:Stmt_Function[1] and subNode:name/scalar:string[#{not_a_superglobals}]]")
  end

  def not_a_superglobals
    "not(#{a_superglobals})"
  end

  def a_superglobals
    language.superglobals.map{ |superglobal| "text() = '#{superglobal}'" }.join(" or ")
  end

  def not_

  # def klass_methods_local_variables ast
  #   ast.xpath(".//node:Expr_Assign/ancestor::node:Stmt_ClassMethod[1] and descendant::node:Expr_ArrayDimFetch[last()][subNode:var/node:Expr_Variable[subNode:name/scalar:string[#{superglobals('and')}]]]")
  # end

  def unique_name ast

  end

  def name ast

  end

end
