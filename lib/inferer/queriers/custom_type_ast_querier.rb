require_relative 'querier'

class CustomTypeAstQuerier < Querier

  def custom_types
    ast.xpath(".//node:Param[subNode:type/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string[last()][not(#{basic_types})]]") +
    ast.xpath(".//node:Stmt_Class")
  end

  def basic_types
    ".='" + language.types.join("' or .='") + "'"
  end

  def name ast
    parameter_type_name = ast.xpath('./subNode:type/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string[last()]').text
    return parameter_type_name if parameter_type_name != ''
    ast.xpath('./subNode:name/scalar:string').text
  end

  def unique_name ast
    parameter_type_unique_name = ast.xpath('./subNode:type/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('\\')
    return global_namespace_unique_name + parameter_type_unique_name if parameter_type_unique_name != ''
    global_namespace_unique_name + ast.xpath('./subNode:namespacedName/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('\\')
  end

end
