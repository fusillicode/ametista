require_relative 'assignement_querier'

class ParametersQuerier < AssignementQuerier

  def functions_parameters ast_root
    ast_root.xpath('.//node:Stmt_Function/subNode:params/array/node:Param')
  end

  def klasses_methods_parameters ast_root
    ast_root.xpath('.//node:Stmt_ClassMethod/subNode:params/array/node:Param')
  end

  def name ast
    ast.xpath('./subNode:name/string').text
  end

  def klass_method ast
    ast.xpath("./ancestor::node:Stmt_ClassMethod")
  end

  def function ast
    ast.xpath("./ancestor::node:Stmt_Function")
  end

end
