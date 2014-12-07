require_relative 'querier'

class KlassesQuerier < Querier

  def klasses ast_root
    ast_root.xpath(".//node:Stmt_Class")
  end

  def name ast
    ast.xpath("./subNode:name/scalar:string").text
  end

  def unique_name ast
    "#{global_namespace_unique_name}#{namespace_separator}#{namespaced_name(ast)}"
  end

  def namespaced_name ast
    ast.xpath('./subNode:namespacedName/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join(namespace_separator)
  end

  def parent_klass_name ast
    ast.xpath('./subNode:extends/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string[last()]').text
  end

  def parent_klass_unique_name ast
    "#{global_namespace_unique_name}#{namespace_separator}#{parent_klass_fully_qualified_name(ast)}"
  end

  def parent_klass_fully_qualified_name ast
    parent_klass_fully_qualified_name_parts(ast)[0..-1].to_a.join(namespace_separator)
  end

  def parent_klass_fully_qualified_name_parts ast
    ast.xpath('./subNode:extends/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string')
  end

  def parent_klass_namespace_unique_name ast
    name_parts = parent_klass_fully_qualified_name_parts(ast)
    case name_parts.size
    when 0
      nil
    when 1
      global_namespace_unique_name
    else
      "#{global_namespace_unique_name}#{namespace_separator}#{parent_klass_namespace_fully_qualified_name(name_parts)}"
    end
  end

  def parent_klass_namespace_fully_qualified_name name_parts
    name_parts[0..-2].to_a.join(namespace_separator).to_s
  end

end
