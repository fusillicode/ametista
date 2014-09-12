require_relative 'querier'

class CustomTypesQuerier < Querier

  def parameters_custom_types ast
    ast.xpath(".//node:Param[subNode:type/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string[last()][not(#{basic_types_list('or')})]]")
  end

  def klasses_custom_types ast
    ast.xpath(".//node:Stmt_Class")
  end

  def basic_types_list operator
    ".='" + language.types.join("' #{operator} .='") + "'"
  end

  def parameter_custom_type_name ast
    ast.xpath('./subNode:type/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string[last()]').text
  end

  def parameter_custom_type_unique_name ast
    "#{global_namespace_unique_name}#{language.namespace_separator}#{ast.xpath('./subNode:type/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('\\')}"
  end

  def klass_custom_type_name ast
    ast.xpath('./subNode:name/scalar:string').text
  end

  def klass_custom_type_unique_name ast
    "#{global_namespace_unique_name}#{language.namespace_separator}#{ast.xpath('./subNode:namespacedName/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('\\')}"
  end

end
