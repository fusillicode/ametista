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
    ast.xpath('./subNode:type/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string[last()]').text ||
    ast.xpath('./subNode:name')
  end

  def unique_name ast
    unique_name = ast.xpath('./subNode:type/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('\\') ||
    ast.xpath('./subNode:namespacedName/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('\\')
    global_namespace_unique_name + unique_name
  end

end
