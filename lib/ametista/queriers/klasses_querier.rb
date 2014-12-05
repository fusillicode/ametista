require_relative 'querier'

class KlassesQuerier < Querier

  def klasses ast_root
    ast_root.xpath(".//node:Stmt_Class")
  end

  def name ast
    ast.xpath("./subNode:name/scalar:string").text
  end

  def unique_name ast
    "#{global_namespace_unique_name}#{namespace_separator}#{ast.xpath('./subNode:namespacedName/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join(namespace_separator)}"
  end

  def namespace_name ast
    namespace_name = ast.xpath('./ancestor::node:Stmt_Namespace[1]/subNode:name/node:Name/subNode:parts/scalar:array/scalar:string[last()]').text
    namespace_name.empty? ?
      global_namespace_name :
      namespace_name
  end

  def namespace_unique_name ast
    namespace_name_parts = namespace_name_parts(ast)
    namespace_name_parts.empty? ?
      global_namespace_unique_name :
      "#{global_namespace_unique_name}#{namespace_separator}#{namespace_name_parts(ast)}"
  end

  def namespace_name_parts ast
    ast.xpath('./ancestor::node:Stmt_Namespace[1]/subNode:name/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join(namespace_separator)
  end

  def parent_klass_name ast
    ast.xpath('./subNode:extends/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string[last()]').text
  end

  def parent_klass_unique_name ast
    "#{global_namespace_unique_name}#{namespace_separator}#{ast.xpath('./subNode:extends/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join(namespace_separator)}"
  end

end

