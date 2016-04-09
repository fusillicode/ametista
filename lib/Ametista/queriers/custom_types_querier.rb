require_relative 'querier'

class CustomTypesQuerier < Querier

  def parameters_custom_types ast_root
    ast_root.xpath(".//Param[type/Name_FullyQualified/parts/array/string[last()][#{not_a_primitive_type}]]")
  end

  def name ast
    ast.xpath('./type/Name_FullyQualified/parts/array/string[last()]').text
  end

  def name_parts ast
    ast.xpath('./type/Name_FullyQualified/parts/array/string')
  end

end
