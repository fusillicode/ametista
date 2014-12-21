require_relative '../schema'

class Querier

  extend Initializer
  initialize_with ({
    a_superglobal: 'superglobals',
    a_primitive_type: 'primitive_types',
    an_instance_property: 'instance_property',
    a_self_property: 'self_property',
    a_parent_property: 'parent_property',
    a_static_property: 'static_property'
  })

  def initialize
    super
    set_query_strings
    set_negated_query_strings
  end

  def query_string language_entity
    Array.wrap(Global.lang.php[language_entity]).map{ |value| "text() = '#{value}'" }.join(" or ")
  end

  def set_query_strings
    default_attributes.each do |instance_attribute, language_entity|
      instance_variable_set("@#{instance_attribute}", query_string(language_entity))
    end
  end

  def set_negated_query_strings
    default_attributes.each do |instance_attribute, language_entity|
      self.class.send(:define_method, "not_#{instance_attribute}") do
        "not(#{instance_variable_get("@#{instance_attribute}")})"
      end
    end
  end

  def global_namespace_name
    Global.lang.php.global_namespace.name
  end

  def a_klass_property
    "not(#{an_instance_property} and #{a_self_property} and #{a_parent_property} and #{a_static_property})"
  end

  def not_a_klass_property
    "#{an_instance_property} or #{a_self_property} or #{a_parent_property} or #{a_static_property}"
  end

  def not_a_property
    "not(#{an_instance_property} or #{a_self_property} or #{a_parent_property} or #{a_static_property})"
  end

  def a_local_variable
    "#{not_a_superglobal} and #{not_a_property}"
  end

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

  def function ast
    ast.xpath('./ancestor::Stmt_Function[1]')
  end

  def klass_method ast
    ast.xpath('./ancestor::Stmt_ClassMethod[1]')
  end

  def rhs ast
    ast.xpath('./ancestor::var/following-sibling::expr[1]')
  end

  # def namespace_name ast
  #   exit
  #   namespace_name_parts = namespace_name_parts(ast)
  #   namespace_name_parts.empty? ?
  #     global_namespace_name :
  #     "#{global_namespace_name}#{namespace_separator}#{namespace_name_parts}"
  # end

  # def namespace_name_parts ast
  #   exit
  #   ast.xpath('./ancestor::Stmt_Namespace[1]/name/Name/parts/array/string')[0..-1].to_a.join(namespace_separator)
  # end

  def method_missing method_name, *args, &block
    if self.respond_to? method_name
      self.public_send method_name, *args, &block
    elsif Global.lang.php[method_name]
      Global.lang.php[method_name]
    end
  end

end
