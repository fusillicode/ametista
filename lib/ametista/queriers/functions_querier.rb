require_relative 'querier'

class FunctionsQuerier < Querier

  def functions ast_root
    ast_root.xpath('.//array/Stmt_Function')
  end

  def function_namespaced_name_parts ast
    ast.xpath('./namespacedName/Name/parts/array/string')
  end

end
