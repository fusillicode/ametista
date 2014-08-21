require_relative 'querier'

class ParametersAstQuerier < Querier

  def parameters
    ast.xpath('.//node:Param')
  end

  def parent_type ast
    ast.xpath('./ancestor::node:Stmt_ClassMethod[1]') ||
    ast.xpath('./ancestor::node:Stmt_Function[1]')
  end

  def parent_name ast
    ast.xpath('./ancestor::node:Stmt_Namespace[1]/subNode:name//scalar:string').text
  end

  def parent_unique_name ast
    global_namespace_unique_name + ast.xpath('./ancestor::node:Stmt_Namespace[1]/subNode:namespacedName/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('\\')
  end

  def name ast
    ast.xpath('./subNode:name/scalar:string').text
  end

  def unique_name ast
    global_namespace_unique_name + ast.xpath('./subNode:namespacedName/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('\\')
  end

  def type ast
    ast.xpath('./subNode:type/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('\\')
  end

end
