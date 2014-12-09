# TODO valutare se eliminare AssignementQuerier e collassare rhs in Querier
class AssignementQuerier < Querier

  def rhs ast
    ast.xpath('./ancestor::var/following-sibling::expr[1]')
  end

end
