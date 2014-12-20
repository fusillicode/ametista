require_relative 'querier'

class FunctionsQuerier < Querier

  def functions ast_root
    ast_root.xpath('.//array/Stmt_Function')
  end

  def name ast
    ast.xpath('./name/string').text
  end

  def function_namespaced_name_parts ast
    ast.xpath('./namespacedName/Name/parts/array/string')
  end

  def statements ast
    ast.xpath('./stmts/array').to_s
  end

end
