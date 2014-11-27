require_relative 'querier'

class CustomTypesQuerier < Querier

  def parameters_custom_types ast_root
    ast_root.xpath(".//node:Param[subNode:type/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string[last()][#{not_a_primitive_type}]]")
  end

  def klasses_custom_types ast_root
    ast_root.xpath(".//node:Stmt_Class")
  end

  def parameter_custom_type_name ast
    ast.xpath('./subNode:type/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string[last()]').text
  end

  def parameter_custom_type_unique_name ast
    "#{global_namespace_unique_name}#{namespace_separator}#{ast.xpath('./subNode:type/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join(namespace_separator)}"
  end

  def klass_custom_type_name ast
    ast.xpath('./subNode:name/scalar:string').text
  end

  def klass_custom_type_unique_name ast
    "#{global_namespace_unique_name}#{namespace_separator}#{ast.xpath('./subNode:namespacedName/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join(namespace_separator)}"
  end

end
