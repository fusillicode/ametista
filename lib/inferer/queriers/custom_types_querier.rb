require_relative 'querier'

class CustomTypesAstQuerier < Querier

  def custom_types ast
    parameters_custom_types(ast) + klasses(ast)
  end

  def name ast
    parameter_custom_type_name = parameter_custom_type_name(ast)
    return parameter_custom_type_name unless parameter_custom_type_name == ''
    klass_name(ast)
  end

  def unique_name ast
    parameter_custom_type_unique_name = parameter_custom_type_unique_name(ast)
    return parameter_custom_type_unique_name unless parameter_custom_type_unique_name == ''
    klass_unique_name(ast)
  end

  def parameters_custom_types ast
    ast.xpath(".//node:Param[subNode:type/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string[last()][not(#{basic_types_list('or')})]]")
  end

  def klasses ast
    ast.xpath(".//node:Stmt_Class")
  end

  def basic_types_list operator
    ".='" + language.types.join("' #{operator} .='") + "'"
  end

  def parameter_custom_type_name ast
    ast.xpath('./subNode:type/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string[last()]').text
  end

  def klass_name ast
    ast.xpath('./subNode:name/scalar:string').text
  end

  def parameter_custom_type_unique_name ast
    ast.xpath('./subNode:type/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('\\')
  end

  def klass_unique_name ast
    ast.xpath('./subNode:namespacedName/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('\\')
  end

end
