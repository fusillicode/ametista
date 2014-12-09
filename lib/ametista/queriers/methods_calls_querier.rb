require_relative 'querier'

class MethodsCallsQuerier < Querier

  def methods_calls ast
    ast.xpath('./node:Expr_MethodCall')
  end

  def variable ast
    ast.xpath('./var')
  end

  def method ast
    ast.xpath('./name')
  end

end
