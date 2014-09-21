require_relative '../schema'

# TODO Language.first() potrebbe essere storata come proprietà locale in modo
# da evitare continue query sul db...ma in che momento la storo? devo essere sicuro
# che i dati siano stati prima effettivamente inseriti per il linguaggio

class Querier

  { superglobals: :a_superglobal,
    primitive_types: :a_primitive_type,
    object_property: :an_object_property,
    self_class_property: :a_self_class_property,
    parent_class_property: :a_parent_class_property,
    static_class_property: :a_static_class_property
  }.each do |property, method|
    define_method method do
      Language.first()[property].map{ |value| "text() = '#{value}'" }.join(" or ")
    end
    define_method "not_#{method}" do
      "not(#{method})"
    end
  end

  def global_namespace_name
    Language.first().global_namespace[:name]
  end

  def global_namespace_unique_name
    Language.first().global_namespace[:unique_name]
  end

  def class_property
    "not(#{an_object_property} and #{a_self_class_property} and #{a_parent_class_property} and #{a_static_class_property})"
  end

  def not_class_property
    "#{an_object_property} or #{a_self_class_property} or #{a_parent_class_property} or #{a_static_class_property}"
  end

  def method_missing method_name, *args, &block
    if self.respond_to? method_name
      self.public_send method_name, *args, &block
    elsif Language.first().respond_to? method_name
      Language.first().public_send method_name, *args, &block
    end
  end

end
