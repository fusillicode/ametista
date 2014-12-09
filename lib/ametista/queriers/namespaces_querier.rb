require_relative 'querier'

class NamespacesQuerier < Querier

  def namespaces ast_root
    ast_root.xpath('.//node:Stmt_Namespace')
  end

  def unique_name ast
    "#{global_namespace_unique_name}#{namespace_separator}#{namespace_name_parts(ast)}"
  end

  def namespace_name_parts ast
    ast.xpath('./name/node:Name/parts/array/string')[0..-1].to_a.join(namespace_separator)
  end

  def statements ast
    ast.xpath('./stmts/array/*[name() != "node:Stmt_Function" and name() != "node:Stmt_Class"]').to_s
  end

  def global_namespace_statements ast_root
    ast_root.xpath('/AST/array/*[name() != "node:Stmt_Function" and name() != "node:Stmt_Class" and name() != "node:Stmt_Namespace"]').to_s
  end

end
