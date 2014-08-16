require_relative 'querier'

class ANamespaceAstQuerier < Querier

  def namespaces
    ast.xpath('.//node:Stmt_Namespace')
  end

  def inline_namespaces
    ast.xpath('./subNode:name/node:Name/subNode:parts/scalar:array/scalar:string')
  end

  def namespace_name
    ast.xpath('./subNode:name/node:Name/subNode:parts/scalar:array/scalar:string[last()]').text
  end

  def namespace_unique_name
    subnamespaces = ast.xpath('./subNode:name/node:Name/subNode:parts/scalar:array/scalar:string')
    root_unique_name + subnamespaces.map{ |subnamespace| "\\#{subnamespace.text}" }.join
  end

  def statements
    ast.xpath('./subNode:stmts/scalar:array/*[name() != "node:Stmt_Function" and name() != "node:Stmt_Class"]')
  end

  # le variabili assegnate
  def assignements
    ast.xpath('./subNode:stmts/scalar:array/node:Expr_Assign/subNode:var')
  end

  def functions
    ast.xpath('./subNode:stmts/scalar:array/node:Stmt_Function')
  end

  def classes
    ast.xpath('./subNode:stmts/scalar:array/node:Stmt_Class')
  end

end
