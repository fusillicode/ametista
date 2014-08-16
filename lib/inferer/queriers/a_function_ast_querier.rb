require_relative 'querier'

class AFunctionAstQuerier

  def get_name(ast)
    ast.xpath('./subNode:name/scalar:string').text
  end

  def get_unique_name(ast)
    '\\\\' << ast.xpath('./subNode:namespacedName/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('\\')
  end

  def get_return_statements(ast)
    ast.xpath('./subNode:stmts/scalar:array/node:Stmt_Return')
  end

  def get_statements(ast)
    ast.xpath('./subNode:stmts/scalar:array')
  end

  def get_parameters(ast)
    ast.xpath('./subNode:params/scalar:array/node:Param')
  end

  def get_parameter_name(ast)
    ast.xpath('./subNode:name/scalar:string').text
  end

  def get_parameter_unique_name(parameter_name)
    model.send("current_#{procedure_type}").unique_name << "\\#{parameter_name}"
  end

  def get_parameter_default_value(ast)
    ast.xpath('./subNode:default')
  end

  def get_assignements_and_global_definitions(ast)
    ast.xpath('./subNode:stmts/scalar:array/*[name() = "node:Expr_Assign" or name() = "node:Stmt_Global"]')
  end

end
