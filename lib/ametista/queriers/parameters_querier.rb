require_relative 'assignement_querier'

class ParametersQuerier < AssignementQuerier

  def functions_parameters ast_root
    ast_root.xpath('.//Stmt_Function/params/array/Param')
  end

  def klasses_methods_parameters ast_root
    ast_root.xpath('.//Stmt_ClassMethod/params/array/Param')
  end

end
