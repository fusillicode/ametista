require_relative '../schema'

# TODO Language.first() potrebbe essere storata come proprietà locale in modo
# da evitare continue query sul db...ma in che momento la storo? devo essere sicuro
# che i dati siano stati prima effettivamente inseriti per il linguaggio

class Querier

  { superglobals: :a_superglobal,
    primitive_types: :a_primitive_type,
    instance_property: :an_instance_property,
    self_property: :a_self_property,
    parent_property: :a_parent_property,
    static_property: :a_static_property
  }.each do |property, method|
    define_method method do
      # TODO qui si fa ongi volta molta roba per costruire la stringa da utilizzare nella query XPath
      # Si potrebbe cercare di salvare le stringhe in variabili d'istanza (magari con l'Initializer)
      Array.wrap(Global.lang.php[property]).map{ |value| "text() = '#{value}'" }.join(" or ")
    end
    define_method "not_#{method}" do
      "not(#{public_send("#{method}")})"
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
