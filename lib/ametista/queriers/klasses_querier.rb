require_relative 'querier'

class KlassesQuerier < Querier

  def klasses ast_root
    ast_root.xpath(".//node:Stmt_Class")
  end

  def name ast
    ast.xpath("./subNode:name/scalar:string").text
  end

  def unique_name ast
    "#{global_namespace_unique_name}#{namespace_separator}#{namespaced_name(ast)}"
  end

  def namespaced_name ast
    ast.xpath('./subNode:namespacedName/node:Name/subNode:parts/scalar:array/scalar:string')[0..-1].to_a.join(namespace_separator)
  end

  def parent_klass_name ast
    ast.xpath('./subNode:extends/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string[last()]').text
  end

  def parent_klass_unique_name ast
    "#{global_namespace_unique_name}#{namespace_separator}#{parent_klass_fully_qualified_name(ast)}"
  end

  def parent_klass_fully_qualified_name ast
    parent_klass_fully_qualified_name_parts(ast)[0..-1].to_a.join(namespace_separator)
  end

  # prendo tutto tranne l'ultimo elemento dell parent_klass_fully_qualified_name e ci aggiungo i namespace_separator
  # = se ho un solo elemento in parent_klass_fully_qualified_name allora il parent_klass_namespace è quello globale
  # = se non ho nessun elemento in parent_klass_fully_qualified_name allora non ho una parent_klass (questa condizione la verifico comunque
  #   prima di creare la parent_klass)
  def parent_klass_namespace_name ast
    parent_klass_fully_qualified_name_parts = parent_klass_fully_qualified_name_parts(ast)
    case parent_klass_fully_qualified_name_parts.size
    when 0
      nil
    when
      global_namespace_name
    else
      parent_klass_fully_qualified_name[0..-2].to_a.join(namespace_separator)
    end
  end

  def parent_klass_fully_qualified_name_parts ast
    ast.xpath('./subNode:extends/node:Name_FullyQualified/subNode:parts/scalar:array/scalar:string')
  end

  def parent_klass_namespace_unique_name ast
    "#{global_namespace_unique_name}#{namespace_separator}#{parent_klass_namespace_name(ast)}"
  end

end

