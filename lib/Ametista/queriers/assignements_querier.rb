require_relative '../schema'
require_relative 'querier'

class AssignementsQuerier < Querier

  def global_namespace_variables ast_root
    ast_root.xpath("/AST/array/Expr_Assign/descendant::Expr_Variable[name/string[#{not_a_superglobal}]]")
  end

  def superglobals ast_root
    ast_root.xpath(".//Expr_Assign/descendant::Expr_ArrayDimFetch[last()][var/Expr_Variable[name/string[#{a_superglobal}]]]")
  end

  def rhs ast
    ast.xpath('./ancestor::var/following-sibling::expr[1]')
  end

  def rhs_kind ast
    ast.xpath('name(./*[1])')
  end

end
