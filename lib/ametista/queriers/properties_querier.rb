require_relative 'assignement_querier'

class PropertiesQuerier < AssignementQuerier

  def instances_properties ast_root
    ast_root.xpath(".//node:Expr_PropertyFetch[subNode:var[last()]/node:Expr_Variable/subNode:name/scalar:string[#{an_instance_property}]]")
  end

  def self_properties ast_root
    ast_root.xpath(".//node:Expr_StaticPropertyFetch[subNode:class[last()]/node:Name/subNode:parts/scalar:array/scalar:string[last()][#{a_self_property}]]")
  end

  def parent_properties ast_root
    ast_root.xpath(".//node:Expr_StaticPropertyFetch[subNode:class[last()]/node:Name/subNode:parts/scalar:array/scalar:string[last()][#{a_parent_property}]]")
  end

  def klass_properties ast_root
    ast_root.xpath(".//node:Expr_StaticPropertyFetch[subNode:class[last()]/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string[last()][#{a_klass_property}]]")
  end

  # def static_property ast_root
  #   ast_root.xpath(".//node:Expr_StaticPropertyFetch[subNode:class[last()]/node:Expr_Variable/subNode:name/scalar:string[#{a_static_property}]]")
  # end

  def name ast
    ast.xpath('./subNode:name/scalar:string').text
  end

  def klass ast
    ast.xpath('./ancestor::node:Stmt_Class')
  end
  end

  def containing_klass_unique_name ast
    "#{global_namespace_unique_name}#{namespace_separator}#{ast.xpath('./ancestor::node:Stmt_Class[1]/subNode:namespacedName/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join(namespace_separator)}"
  end

  def parent_klass_name ast
    ast.xpath('./ancestor::node:Stmt_Class[1]/subNode:extends/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string[last()]').text
  end

  def parent_klass_unique_name ast
    "#{global_namespace_unique_name}#{namespace_separator}#{parent_klass_name_fully_qualified(ast)}"
  end

  def parent_klass_name_fully_qualified ast
    ast.xpath('./ancestor::node:Stmt_Class[1]/subNode:extends/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join(namespace_separator)
  end

  def klass_name ast
    ast.xpath('./subNode:class/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string[last()]').text
  end

  def klass_unique_name ast
    "#{global_namespace_unique_name}#{namespace_separator}#{klass_name_fully_qualified(ast)}"
  end

  def klass_name_fully_qualified ast
    ast.xpath('./subNode:class/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join(namespace_separator)
  end

end

