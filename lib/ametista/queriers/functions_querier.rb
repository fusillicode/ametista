require_relative 'ast_querier'

class FunctionsQuerier < AstQuerier

  def functions ast_root
    ast_root.xpath('.//array/Stmt_Function')
  end

end
