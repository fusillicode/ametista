require_relative 'querier'

class NamespacesQuerier < Querier

  def namespaces ast
    ast.xpath('.//node:Stmt_Namespace')
  end

  def name ast
    ast.xpath('./subNode:name/node:Name/subNode:parts/scalar:array/scalar:string[last()]').text
  end

  def unique_name ast
    "#{global_namespace_unique_name}#{ast.xpath('./subNode:name/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('\\')}"
  end

  def statements ast
    ast.xpath('./subNode:stmts/scalar:array/*[name() != "node:Stmt_Function" and name() != "node:Stmt_Class"]')
  end

  def global_namespace_statements ast
    ast.xpath('/AST/scalar:array/*[name() != "node:Stmt_Function" and name() != "node:Stmt_Class"]')
  end

  # def inline_namespaces
  #   ast.xpath('./subNode:name/node:Name/subNode:parts/scalar:array/scalar:string')
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
