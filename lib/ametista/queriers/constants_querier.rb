require_relative 'querier'

class ConstantsQuerier < Querier

  def defined_constant_name ast
    ast.xpath('./args/array/*[1]/value/Expr_ConstFetch/name/Name/parts/array/string').text
  end

  def defined_constant_rhs ast
    ast.xpath('./args/array/Arg[2]/value/*[1]')
  end

  # def defined_constant_rhs ast
  #   ast.xpath('./args/array/*Arg[3]/value')
  # end

end
