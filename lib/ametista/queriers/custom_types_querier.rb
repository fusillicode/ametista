require_relative 'querier'

class CustomTypesQuerier < Querier

  def parameters_custom_types ast_root
    ast_root.xpath(".//node:Param[subNode:type/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string[last()][#{not_a_primitive_type}]]")
  end

  def parameter_custom_type_name ast
    ast.xpath('./subNode:type/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string[last()]').text
  end

end
