require_relative 'ast_querier'

class KlassesQuerier < AstQuerier

  def klasses ast_root
    ast_root.xpath('.//Stmt_Class')
  end

  def parent_klass_name ast
    ast.xpath('./extends/Name_FullyQualified/parts/array/string[last()]').text
  end

  def parent_klass_fully_qualified_name_parts ast
    ast.xpath('./extends/Name_FullyQualified/parts/array/string')
  end

end
