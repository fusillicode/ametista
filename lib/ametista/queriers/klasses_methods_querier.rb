require_relative 'querier'

class KlassesMethodsQuerier < Querier

  def klasses_methods ast_root
    ast_root.xpath('.//array/Stmt_ClassMethod')
  end

  def klass ast
    ast.xpath('./ancestor::Stmt_Class[1]')
  end

end
