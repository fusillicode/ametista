require_relative 'querier'

class NamespacesAstQuerier < Querier

  def namespaces ast
    ast.xpath('.//node:Stmt_Namespace')
  end

  def name ast
    ast.xpath('./subNode:name/node:Name/subNode:parts/scalar:array/scalar:string[last()]').text
  end

  def unique_name ast
    ast.xpath('./subNode:name/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('\\')
  end

  # def inline_namespaces
  #   ast.xpath('./subNode:name/node:Name/subNode:parts/scalar:array/scalar:string')
  # end

  # def statements
  #   ast.xpath('./subNode:stmts/scalar:array/*[name() != "node:Stmt_Function" and name() != "node:Stmt_Class"]')
  # end

  # # le variabili assegnate
  # def assignements
  #   ast.xpath('./subNode:stmts/scalar:array/node:Expr_Assign')
  # end

  # def functions
  #   ast.xpath('./subNode:stmts/scalar:array/node:Stmt_Function')
  # end

  # def classes
  #   ast.xpath('./subNode:stmts/scalar:array/node:Stmt_Class')
  # end

end
