require_relative 'querier'

class FunctionsQuerier < Querier

  def functions ast_root
    ast_root.xpath('.//array/Stmt_Function')
  end

  def name ast
    ast.xpath('./name/string').text
  end

  def function_namespaced_name_parts ast
    ast.xpath('./namespacedName/Name/parts/array/string')
  end

  def statements ast
    ast.xpath('./stmts/array')
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
