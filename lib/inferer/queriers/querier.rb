require_relative '../schema'

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

  def a_property
    Language.first().property.map{ |property| "text() = '#{property}'" }.join(" or ")
  end

  def not_a_property
    "not(#{a_property})"
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
