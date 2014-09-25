require_relative 'querier'

class PropertiesQuerier < Querier

  def instances_properties ast_root
    ast_root.xpath(".//node:Expr_PropertyFetch[subNode:var[last()]/node:Expr_Variable/subNode:name/scalar:string[#{an_object_property}]]")
  end

  def self_class_properties ast_root
    ast_root.xpath(".//node:Expr_StaticPropertyFetch/subNode:var[last()]/node:Expr_Variable/subNode:name/scalar:string[#{self_class_property}]")
  end

  def parent_class_property ast_root
    ast_root.xpath(".//node:Expr_StaticPropertyFetch/subNode:var[last()]/node:Expr_Variable/subNode:name/scalar:string[#{parent_class_property}]")
  end

  def static_class_property ast_root
    ast_root.xpath(".//node:Expr_StaticPropertyFetch/subNode:var[last()]/node:Expr_Variable/subNode:name/scalar:string[#{static_class_property}]")
  end

  def class_property ast_root
    ast_root.xpath(".//node:Expr_StaticPropertyFetch/subNode:var[last()]/node:Expr_Variable/subNode:name/scalar:string[#{class_property}]")
  end

  def name ast
    ast.xpath('./subNode:name/scalar:string').text
  end

  def unique_name ast
    "#{global_namespace_unique_name}#{namespace_separator}#{ast.xpath('./subNode:namespacedName/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('\\')}"
  end

  def klass_name ast
    ast.xpath('./ancestor::node:Stmt_Class[1]/subNode:name/scalar:string').text
  end

  def klass_unique_name ast
    "#{global_namespace_unique_name}#{namespace_separator}#{ast.xpath('./ancestor::node:Stmt_Class[1]/subNode:namespacedName/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join('\\')}"
  end

end

