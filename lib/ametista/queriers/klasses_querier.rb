require_relative 'querier'

class KlassesQuerier < Querier

  def klasses ast_root
    ast_root.xpath(".//Stmt_Class")
  end

  def name ast
    ast.xpath("./name/string").text
  end

  def klass_namespaced_name_parts ast
    ast.xpath('./namespacedName/Name/parts/array/string')
  end

  def parent_klass_name ast
    ast.xpath('./extends/Name_FullyQualified/parts/array/string[last()]').text
  end

  def parent_klass_fully_qualified_name_parts ast
    ast.xpath('./extends/Name_FullyQualified/parts/array/string')
  end

end
