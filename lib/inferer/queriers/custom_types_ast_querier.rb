require_relative 'querier'

class CustomTypesAstQuerier < Querier

  def custom_types ast
    ast.xpath(".//node:Param[subNode:type/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string[last()][not(#{basic_types_list('or')})]]") +
    ast.xpath(".//node:Stmt_Class")
  end

  def basic_types_list operator
    ".='" + language.types.join("' #{operator} .='") + "'"
  end

  def name ast
    parameter_type_name = ast.xpath('./subNode:type/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string[last()]').text
    return parameter_type_name if parameter_type_name != ''
    ast.xpath('./subNode:name/scalar:string').text
  end

  def unique_name ast
    parameter_type_unique_name = ast.xpath('./subNode:type/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('\\')
    return parameter_type_unique_name if parameter_type_unique_name != ''
    ast.xpath('./subNode:namespacedName/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('\\')
  end

end
