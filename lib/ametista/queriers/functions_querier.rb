require_relative 'querier'

class FunctionsQuerier < Querier

  def functions ast_root
    ast_root.xpath('.//array/Stmt_Function')
  end

end
