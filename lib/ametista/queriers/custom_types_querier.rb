require_relative 'querier'

class CustomTypesQuerier < Querier

  def parameters_custom_types ast_root
    ast_root.xpath(".//node:Param[type/node:Name_FullyQualified/parts/array/string[last()][#{not_a_primitive_type}]]")
  end

  def name ast
    ast.xpath('./type/node:Name_FullyQualified/parts/array/string[last()]').text
  end

  def name_parts ast
    ast.xpath('./type/node:Name_FullyQualified/parts/array/string')
  end

  def namespace_unique_name name_parts
    case name_parts.size
    when 0
      nil
    when 1
      global_namespace_unique_name
    else
      "#{global_namespace_unique_name}#{namespace_separator}#{namespace_fully_qualified_name(name_parts)}"
    end
  end

  def namespace_fully_qualified_name name_parts
    name_parts[0..-2].to_a.join(namespace_separator).to_s
  end

end
