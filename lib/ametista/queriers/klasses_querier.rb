require_relative 'querier'

class KlassesQuerier < Querier

  def klasses ast_root
    ast_root.xpath(".//Stmt_Class")
  end

  def name ast
    ast.xpath("./name/string").text
  end

  def klass_namespaced_name_parts ast
    ast.xpath('./namespacedName/Name/parts/array/string')
  end

  def namespace_name name_parts
    case name_parts.size
    when 0
      nil
    when 1
      global_namespace_name
    else
      "#{global_namespace_name}#{namespace_separator}#{namespace_fully_qualified_name(name_parts)}"
    end
  end

  def namespace_fully_qualified_name name_parts
    name_parts[0..-2].to_a.join(namespace_separator).to_s
  end

  def parent_klass_name ast
    ast.xpath('./extends/Name_FullyQualified/parts/array/string[last()]').text
  end

  def parent_klass_fully_qualified_name_parts ast
    ast.xpath('./extends/Name_FullyQualified/parts/array/string')
  end

end
