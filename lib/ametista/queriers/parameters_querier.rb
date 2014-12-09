require_relative 'assignement_querier'

class ParametersQuerier < AssignementQuerier

  def functions_parameters ast_root
    ast_root.xpath('.//Stmt_Function/params/array/Param')
  end

  def klasses_methods_parameters ast_root
    ast_root.xpath('.//Stmt_ClassMethod/params/array/Param')
  end

  def name ast
    ast.xpath('./name/string').text
  end

  def klass_method ast
    ast.xpath("./ancestor::Stmt_ClassMethod")
  end

  def function ast
    ast.xpath("./ancestor::Stmt_Function")
  end

end
