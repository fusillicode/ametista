require_relative 'ast_querier'

class NamespacesQuerier < AstQuerier

  def namespaces ast_root
    ast_root.xpath('.//Stmt_Namespace')
  end

  def name ast
    "#{global_namespace_name}#{namespace_separator}#{namespace_name_parts(ast)}"
  end

  def namespace_name_parts ast
    ast.xpath('./name/Name/parts/array/string')[0..-1].to_a.join(namespace_separator)
  end

  def statements ast
    ast.xpath('./stmts/array/*[name() != "Stmt_Function" and name() != "Stmt_Class"]').to_s
  end

  def global_namespace_statements ast_root
    ast_root.xpath('/AST/array/*[name() != "Stmt_Function" and name() != "Stmt_Class" and name() != "Stmt_Namespace"]').to_s
  end

end
