require_relative 'querier'

class KlassesQuerier

  def klasses ast_root
    ast_root.xpath(".//node:Stmt_Class")
  end

  def name ast
    ast.xpath("./subNode:name/scalar:string").text
  end

  def unique_name ast
    "#{global_namespace_unique_name}#{namespace_separator}#{ast.xpath('./subNode:namespacedName/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('\\')}"
  end

  def namespace_name ast
    ast.xpath('./ancestor::node:Stmt_Namespace[1]/subNode:name/node:Name/subNode:parts/scalar:array/scalar:string[last()]').text
  end

  def namespace_unique_name ast
    "#{global_namespace_unique_name}#{namespace_separator}#{ast.xpath('./ancestor::node:Stmt_Namespace[1]/subNode:name/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('\\')}"
  end

end

