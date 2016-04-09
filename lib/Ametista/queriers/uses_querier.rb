require_relative '../schema'
require_relative 'querier'

class UsesQuerier < Querier

  def klass_methods_calls ast_root, varible_name
    ast_root.xpath(".//Expr_MethodCall[var/Expr_Variable/name/string[text() = '#{varible_name}']]")
  end

  def static_methods_calls ast_root, varible_name
    ast_root.xpath(".//Expr_StaticCall[var/Expr_Variable/name/string[text() = '#{varible_name}']")
  end

end
