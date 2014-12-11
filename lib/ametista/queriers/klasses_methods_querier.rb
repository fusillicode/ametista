require_relative 'querier'

class KlassesMethodsQuerier < Querier

  def klasses_methods ast_root
    ast_root.xpath('.//array/Stmt_ClassMethod')
  end

  def name ast
    ast.xpath('./name/string').text
  end

  def statements ast
    ast.xpath('./stmts/array').to_s
  end

  def klass ast
    ast.xpath('./ancestor::Stmt_Class[1]')
  end

end
