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

  def namespace_unique_name name_parts
    case name_parts.size
    when 0
      nil
    when 1
      global_namespace_unique_name
    else
      "#{global_namespace_unique_name}#{namespace_separator}#{namespace_fully_qualified_name(name_parts)}"
    end
  end

  def namespace_fully_qualified_name name_parts
    name_parts[0..-2].to_a.join(namespace_separator).to_s
  end

  def klass_fully_qualified_name_parts ast
    ast.xpath('./subNode:class/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string')
  end

end

