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
      Array.wrap(Language.first()[property]).map{ |value| "text() = '#{value}'" }.join(" or ")
    end
    define_method "not_#{method}" do
      "not(#{public_send("#{method}")})"
    end
  end

  def global_namespace_name
    Language.first().global_namespace[:name]
  end

  def global_namespace_unique_name
    Language.first().global_namespace[:unique_name]
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

  def method_missing method_name, *args, &block
    if self.respond_to? method_name
      self.public_send method_name, *args, &block
    elsif Language.first().respond_to? method_name
      Language.first().public_send method_name, *args, &block
    end
  end

end
