require_relative '../schema'
require_relative 'language_querier'

class Querier

  extend Initializer
  initialize_with ({
    language_querier: LanguageQuerier.new,
  })

  def position ast
    [index_of_node_in_parent(ast)].concat(ast.ancestors.map { |ancestor_ast|
      index_of_node_in_parent(ancestor_ast) + 1 rescue NoMethodError nil
    }.compact).reverse
  end

  def index_of_node_in_parent ast
    ast.parent.children.index(ast)
  end

  def name ast
    ast.xpath('./name/string').text
  end

  def statements ast
    ast.xpath('./stmts/array').to_s
  end

  def namespace_name name_parts
    case name_parts.size
    when 0
      nil
    when 1
      global_namespace_name
    else
      "#{global_namespace_name}#{namespace_separator}#{namespace_fully_qualified_name(name_parts)}"
    end
  end

  def namespace_fully_qualified_name name_parts
    name_parts[0..-2].to_a.join(namespace_separator).to_s
  end

  def procedure_namespaced_name_parts ast
    ast.xpath('./namespacedName/Name/parts/array/string')
  end

  def namespace ast
    ast.xpath('./ancestor::Stmt_Namespace[1]')
  end

  def klass ast
    ast.xpath('./ancestor::Stmt_Class[1]')
  end

  def function ast
    ast.xpath('./ancestor::Stmt_Function[1]')
  end

  def klass_method ast
    ast.xpath('./ancestor::Stmt_ClassMethod[1]')
  end

  def rhs ast
    ast.xpath('./ancestor::var/following-sibling::expr[1]')
  end

  def method_missing method_name, *args, &block
    if self.respond_to? method_name
      self.public_send method_name, *args, &block
    elsif language_querier.respond_to? method_name
      language_querier.public_send method_name, *args, &block
    end
  end

end
