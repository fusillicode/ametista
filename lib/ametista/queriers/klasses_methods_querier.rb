require_relative 'ast_querier'

class KlassesMethodsQuerier < AstQuerier

  def klasses_methods ast_root
    ast_root.xpath('.//array/Stmt_ClassMethod')
  end

end
