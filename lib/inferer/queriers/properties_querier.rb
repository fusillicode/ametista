require_relative 'querier'

class PropertiesQuerier < Querier

  def instances_properties ast_root
    ast_root.xpath(".//node:Expr_PropertyFetch[subNode:var[last()]/node:Expr_Variable/subNode:name/scalar:string[#{an_instance_property}]]")
  end

  def instance_property_name ast
    ast.xpath('./subNode:name/scalar:string').text
  end

  def self_properties ast_root
    ast_root.xpath(".//node:Expr_StaticPropertyFetch/subNode:var[last()]/node:Expr_Variable/subNode:name/scalar:string[#{a_self_property}]")
  end

  def parent_properties ast_root
    ast_root.xpath(".//node:Expr_StaticPropertyFetch/subNode:var[last()]/node:Expr_Variable/subNode:name/scalar:string[#{a_parent_property}]")
  end

  def static_property ast_root
    ast_root.xpath(".//node:Expr_StaticPropertyFetch/subNode:var[last()]/node:Expr_Variable/subNode:name/scalar:string[#{a_static_property}]")
  end

  def class_property ast_root
    ast_root.xpath(".//node:Expr_StaticPropertyFetch/subNode:var[last()]/node:Expr_Variable/subNode:name/scalar:string[#{a_class_property}]")
  end

  def klass_name ast
    ast.xpath('./ancestor::node:Stmt_Class[1]/subNode:name/scalar:string').text
  end

  def klass_unique_name ast
    "#{global_namespace_unique_name}#{namespace_separator}#{ast.xpath('./ancestor::node:Stmt_Class[1]/subNode:namespacedName/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('\\')}"
  end

end

