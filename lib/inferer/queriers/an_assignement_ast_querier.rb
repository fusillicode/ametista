require_relative 'querier'

class AnAssignementAstQuerier < Querier

  def variable
    ast.xpath('./subNode:var')
  end

  def rhs
    ast.xpath('./subNode:expr').to_s
  end

end
