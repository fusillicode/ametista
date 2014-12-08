require_relative 'querier'

class KlassesMethodsQuerier < Querier

  def klasses_methods ast_root
    ast_root.xpath('.//scalar:array/node:Stmt_ClassMethod')
  end

  def name ast
    ast.xpath('./subNode:name/scalar:string').text
  end

  def statements ast
    ast.xpath('./subNode:stmts/scalar:array')
  end

  def klass ast
    ast.xpath('./ancestor::node:Stmt_Class[1]')
  end

end
