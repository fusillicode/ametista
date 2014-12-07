require_relative 'querier'

class KlassesMethodsQuerier < Querier

  def klasses_methods ast_root
    ast_root.xpath('.//scalar:array/node:Stmt_ClassMethod')
  end

  def name ast
    ast.xpath('./subNode:name/scalar:string').text
  end

  def statements ast
    ast.xpath('./subNode:stmts/scalar:array')
  end

  def klass_name ast
    ast.xpath('./ancestor::node:Stmt_Class[1]/subNode:name/scalar:string').text
  end

  def klass_namespaced_name_parts ast
    ast.xpath('./ancestor::node:Stmt_Class[1]/subNode:namespacedName/node:Name/subNode:parts/scalar:array/scalar:string')
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

end
