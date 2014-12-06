require_relative 'querier'

class FunctionsQuerier < Querier

  def functions ast_root
    ast_root.xpath('.//scalar:array/node:Stmt_Function')
  end

  def name ast
    ast.xpath('./subNode:name/scalar:string').text
  end

  def unique_name ast
    "#{global_namespace_unique_name}#{namespace_separator}#{namespaced_name(ast)}"
  end

  def namespaced_name ast
    ast.xpath('./subNode:namespacedName/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join(namespace_separator)
  end

  def statements ast
    ast.xpath('./subNode:stmts/scalar:array')
  end







end
