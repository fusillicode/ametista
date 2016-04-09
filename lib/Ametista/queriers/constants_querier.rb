require_relative 'querier'

class ConstantsQuerier < Querier

  def defined_constants ast_root
    ast_root.xpath(".//Expr_FuncCall[name/Name/parts/array/string[text() = 'define']]")
  end

  def klass_constants ast_root
    ast_root.xpath(".//Expr_FuncCall/name/Name/parts/array/string/define")
  end

  def defined_constant_name ast
    ast.xpath('./args/array/*[1]/value/Scalar_String/value/string').text
  end

  def defined_constant_rhs ast
    ast.xpath('./args/array/Arg[2]/value/*[1]')
  end

end
