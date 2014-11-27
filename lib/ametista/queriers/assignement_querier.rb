class AssignementQuerier < Querier

  def rhs ast
    ast.xpath('./ancestor::subNode:var/following-sibling::subNode:expr[1]')
  end

end
