require_relative 'querier'

class PropertiesQuerier < Querier

  def instances_properties ast_root
    ast_root.xpath(".//Expr_PropertyFetch[var[last()]/Expr_Variable/name/string[#{an_instance_property}]]")
  end

  def self_properties ast_root
    ast_root.xpath(".//Expr_StaticPropertyFetch[class[last()]/Name/parts/array/string[last()][#{a_self_property}]]")
  end

  def parent_properties ast_root
    ast_root.xpath(".//Expr_StaticPropertyFetch[class[last()]/Name/parts/array/string[last()][#{a_parent_property}]]")
  end

  def klass_properties ast_root
    ast_root.xpath(".//Expr_StaticPropertyFetch[class[last()]/Name_FullyQualified/parts/array/string[last()][#{a_klass_property}]]")
  end

  # def static_property ast_root
  #   ast_root.xpath(".//Expr_StaticPropertyFetch[class[last()]/Expr_Variable/name/string[#{a_static_property}]]")
  # end

  def klass_name ast
    ast.xpath('./class/Name_FullyQualified/parts/array/string[last()]').text
  end

  def klass_fully_qualified_name_parts ast
    ast.xpath('./class/Name_FullyQualified/parts/array/string')
  end

end

