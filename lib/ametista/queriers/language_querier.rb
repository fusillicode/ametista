require_relative '../schema'

# TODO sistemare i parametri di inizializzazione ed aggiungere fra questi anche il linguaggio che si vuole considerare

class LanguageQuerier

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

  def method_missing method_name, *args, &block
    if self.respond_to? method_name
      self.public_send method_name, *args, &block
    elsif Global.lang.php[method_name]
      Global.lang.php[method_name]
    end
  end

end
