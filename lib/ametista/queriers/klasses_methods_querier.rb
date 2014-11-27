require_relative 'querier'

class KlassesMethodsQuerier < Querier

  def klasses_methods ast_root
    ast_root.xpath('.//scalar:array/node:Stmt_ClassMethod')
  end

  def name ast
    ast.xpath('./subNode:name/scalar:string').text
  end

  def unique_name ast
    "#{klass_unique_name(ast)}#{namespace_separator}#{ast.xpath('./subNode:name/scalar:string').text}"
  end

  def statements ast
    ast.xpath('./subNode:stmts/scalar:array')
  end

  def klass_name ast
    ast.xpath('./ancestor::node:Stmt_Class[1]/subNode:name/scalar:string').text
  end

  def klass_unique_name ast
    "#{global_namespace_unique_name}#{namespace_separator}#{ast.xpath('./ancestor::node:Stmt_Class[1]/subNode:namespacedName/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join(namespace_separator)}"
  end

end
