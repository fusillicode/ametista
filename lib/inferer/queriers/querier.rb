require_relative '../schema'

# TODO Language.first() potrebbe essere storata come proprietà locale in modo
# da evitare continue query sul db...ma in che momento la storo? devo essere sicuro
# che i dati siano stati prima effettivamente inseriti per il linguaggio

class Querier

  def global_namespace_name
    Language.first().global_namespace[:name]
  end

  def global_namespace_unique_name
    Language.first().global_namespace[:unique_name]
  end

  def a_superglobal
    Language.first().superglobals.map{ |superglobal| "text() = '#{superglobal}'" }.join(" or ")
  end

  def not_a_superglobal
    "not(#{a_superglobal})"
  end

  def an_object_property
    "text() = '#{Language.first().object_property}'"
  end

  def not_an_object_property
    "not(#{an_object_property})"
  end

  def a_self_class_property
    "text() = '#{Language.first().self_class_property}'"
  end

  def a_parent_class_property
    "text() = '#{Language.first().parent_class_property}'"
  end

  def a_static_class_property
    "text() = '#{Language.first().static_class_property}'"
  end

  def a_class_property
    "not(#{an_object_property} and #{a_self_class_property} and #{a_parent_class_property} and #{a_static_class_property})"
  end

  def a_primitive_type
    Language.first().primitive_types.map{ |primitive_type| "text() = '#{primitive_type}'" }.join(" or ")
  end

  def not_a_primitive_type
    "not(#{a_primitive_type})"
  end

  def method_missing method_name, *args, &block
    if self.respond_to? method_name
      self.public_send method_name, *args, &block
    elsif Language.first().respond_to? method_name
      Language.first().public_send method_name, *args, &block
    end
  end

end
