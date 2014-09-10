require_relative 'querier'

class FunctionsAstQuerier < Querier

  def functions ast
    ast.xpath('.//subNode:stmts/scalar:array/node:Stmt_Function')
  end

  def parent_name ast
    ast.xpath('./ancestor::node:Stmt_Namespace[1]/subNode:name/node:Name/subNode:parts/scalar:array/scalar:string[last()]').text
  end

  def parent_unique_name ast
    ast.xpath('./ancestor::node:Stmt_Namespace[1]/subNode:name/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('\\')
  end

  def name ast
    ast.xpath('./subNode:name/scalar:string').text
  end

  def unique_name ast
    ast.xpath('./subNode:namespacedName/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('\\')
  end

  def return_values ast
    ast.xpath('./subNode:stmts/scalar:array/node:Stmt_Return')
  end

  # def statements(ast)
  #   ast.xpath('./subNode:stmts/scalar:array')
  # end

  # def parameters(ast)
  #   ast.xpath('./subNode:params/scalar:array/node:Param')
  # end

  # def parameter_name(ast)
  #   ast.xpath('./subNode:name/scalar:string').text
  # end

  # def parameter_unique_name(parameter_name)
  #   model.send("current_#{procedure_type}").unique_name << "\\#{parameter_name}"
  # end

  # def parameter_default_value(ast)
  #   ast.xpath('./subNode:default')
  # end

  # def assignements_and_global_definitions(ast)
  #   ast.xpath('./subNode:stmts/scalar:array/*[name() = "node:Expr_Assign" or name() = "node:Stmt_Global"]')
  # end

end
