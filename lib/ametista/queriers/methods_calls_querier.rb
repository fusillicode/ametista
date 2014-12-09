require_relative 'querier'

class MethodsCallsQuerier < Querier

  def methods_calls ast
    ast.xpath('./node:Expr_MethodCall')
  end

  def variable ast
    ast.xpath('./subNode:var')
  end

  def method ast
    ast.xpath('./subNode:name')
  end

end
